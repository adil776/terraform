provider "aws" {

	region = "ap-south-1"
	profile = "adil"
}

variable "enter_your_key" {
type=string
} 	

resource "aws_key_pair" "deployer" {
  key_name   = "var.enter_your_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

resource "aws_security_group" "allow_tls" {

	name = "allow_tls"
	description = "Allow HTTP and SSH inbound traffic"
	
	ingress	{
		
		from_port = 80
      		to_port = 80
      		protocol = "tcp"
      		cidr_blocks = ["0.0.0.0/0"]
      		ipv6_cidr_blocks = ["::/0"]
      	}
      	
      	ingress {
      		
      		from_port = 22
      		to_port = 22
      		protocol = "tcp"
      		cidr_blocks = ["0.0.0.0/0"]
      		ipv6_cidr_blocks = ["::/0"]
      	}
      	
      	ingress {
      		
      		from_port = -1
      		to_port = -1
      		protocol = "icmp"
      		cidr_blocks = ["0.0.0.0/0"]
      		ipv6_cidr_blocks = ["::/0"]
      	}
      	
      	egress {
      	
      		from_port = 0
      		to_port = 0
      		protocol = "-1"
      		cidr_blocks = ["0.0.0.0/0"]
      	}
}

// aws insatance deploying
resource "aws_instance" "myos1" {
ami           = "ami-0447a12f28fddb066"
instance_type = "t2.micro"
key_name   = var.enter_your_key
security_groups=["${aws_security_group.allow_tls.name}"]
connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key= file("C:/Users/Dell/Downloads/key1.pem")
    host     = aws_instance.myos1.public_ip
  }
//remote provisioner
  provisioner "remote-exec" {
    inline = [
     "sudo yum install git -y",
     "sudo yum install httpd php -y",
     "sudo systemctl restart httpd",
     "sudo systemctl enable httpd" 
    ]
  }
  tags = {
    Name = "adil_instance"
  }
}

resource "aws_ebs_volume" "vol" {
	availability_zone  = "ap-south-1b"
	size		   = 1
	tags = {
	  Name = "vol1ebs"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.vol.id}"
  instance_id = "${aws_instance.myos1.id}"
  force_detach = true
}

resource "null_resource" "formatgit" {

depends_on  = [
	aws_volume_attachment.ebs_att,
     ]

	connection {
		type  = "ssh"
		user  = "ec2-user"
		private_key  = file("C:/Users/Dell/Downloads/key1.pem")
		host  = aws_instance.myos1.public_ip
	}
	provisioner "remote-exec" {
		inline = [ 
			     "sudo mkfs -t ext4 /dev/xvdc",
			     "sudo mount /dev/xvdc /var/www/html",
			     "sudo rm -rf /var/www/html/*",
			     "sudo git clone https://github.com/adil776/terraform.git /var/www/html/",
		             "sudo su <<EOF",
     			     "echo \"${aws_cloudfront_distribution.cloud_dist.domain_name}\" >> /var/www/html/my.txt",
     			     "EOF",
    			     "sudo systemctl restart httpd"
       ]
		
	}
	
}


resource "aws_s3_bucket" "mys31" {
  bucket = "adil786"
  acl    = "public-read"

  tags = {
    Name  = "My_bucket"
    Environment = "Dev"
  }
}
//importing github file to local directory
resource "null_resource" "cloning" {
depends_on=[ aws_s3_bucket.mys31]
  provisioner "local-exec" {
    command = "git clone https://github.com/adil776/terraform.git my"
  }
}
//creating s3-bucket-object 
resource "aws_s3_bucket_object" "object" {
  bucket = "adil786"
  key    = "adil.JPG"
  source = "my/adil.JPG"
  acl="public-read"
depends_on= [aws_s3_bucket.mys31,null_resource.cloning]
}


//creating cloudfront distribution
resource "aws_cloudfront_distribution" "cloud_dist" {
    origin {
         domain_name = "${aws_s3_bucket.mys31.bucket_regional_domain_name}"
         origin_id   = "${aws_s3_bucket.mys31.bucket}"
 
        custom_origin_config {
            http_port = 80
            https_port = 80
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
    }
    # By default, show index.html file
    default_root_object = "index.php"
    enabled = true
    # If there is a 404, return index.html with a HTTP 200 Response
    custom_error_response {
        error_caching_min_ttl = 3000
        error_code = 404
        response_code = 200
        response_page_path = "/index.php"
    }

default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.mys31.bucket}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE","IN"]
    }
  }

    # SSL certificate for the service.
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}
resource  "null_resource"  "myres1"{
depends_on=[
            null_resource.myres1,
            aws_cloudfront_distribution.cloud_dist

]
provisioner "local-exec" {
    command = "start chrome ${aws_instance.myos1.public_ip}"
  }
}
