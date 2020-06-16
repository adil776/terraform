<html>
<body>
<h1>ADIL</h1>

<p>WELCOME</p>
<p>THIS IS A TERRAFORM WEBPAGE</p>
<br>
<?php
  $cloudfront_url = `head -n1 my.txt`;
  $img_path = "https://".$cloudfront_url."/img.jpg";
  echo "<br>";
  echo "<img src='{$img_path}' width=300 height=300>";
?>
</body>
</html>
