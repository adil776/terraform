<html>
<body>
<style>
background:aqua
<h1>ADIL</h1>

<p>WELCOME</p>
<p>THIS IS A TERRAFORM WEBPAGE</p>
<br>
<?php
  $cloudfront_url = `head -n1 my.txt`;
  $img_path = "https://".$cloudfront_url."/img.jpg";
  $im_path = "https://".aws_instance.myos1.public_ip."/img.jpg";
  $i_path = "https://".C:/Users/Dell/Desktop/terra/task1."/img.jpg";
  echo "<br>";
  echo "<img src='{$img_path}' width=200 height=200>";
  echo "<img src='{$im_path}' width=200 height=200>";
  echo "<img src='{$i_path}' width=200 height=200>";
?>
</body>
</html>
</style>
