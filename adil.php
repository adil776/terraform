<html>
<body>
<h1>ADIL</h1>
<h3>KING OG BLOGGING</h3>

<p>WELCOME</p>
<p>THIS IS A TERRAFORM WEBPAGE</p>
<br>
<?php
  $cloudfront_url = `head -n1 mydesti.txt`;
  $img_path = "https://".$cloudfront_url."/spider_man.jpg";
  echo "<br>";
  echo "<img src='{$img_path}' width=200 height=200>";
?>
</body>
</html>