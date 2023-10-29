<?php

# ===============================

$title_file_path = "./.pwiki_data/title.txt";
$content_file_path = "./.pwiki_data/content.txt";

// echo $_POST["password"];
if (isset($_POST["password"])) {
  $pw_file_path = "./.pwiki_data/password.txt";

  $CONFIG_PASSWORD = false;
  if (file_exists($pw_file_path)) {
    $CONFIG_PASSWORD = trim(file_get_contents($pw_file_path));
  } 
  // echo $CONFIG_PASSWORD;
  
  if ($CONFIG_PASSWORD !== false && $CONFIG_PASSWORD === trim($_POST["password"])) {
    // echo "okok";
    if (isset($_POST["page_title"])) {
      file_put_contents($title_file_path, trim($_POST["page_title"]));
    }

    if (isset($_POST["page_content"])) {
      file_put_contents($content_file_path, trim($_POST["page_content"]));
    }
    // $_COOKIE['pwiki_password'] = $CONFIG_PASSWORD;
    setcookie("pwiki_password", $CONFIG_PASSWORD, time() + 360000, "./");
  }
  else {
    // echo "no";
  }
}


# ===============================


$PAGE_TITLE = "pwiki";

if (file_exists($title_file_path)) {
  $PAGE_TITLE = file_get_contents($title_file_path);
} 

$PAGE_CONTENT = "Welcome to pwiki!";

if (file_exists($content_file_path)) {
  $PAGE_CONTENT = file_get_contents($content_file_path);
}
?><!DOCTYPE html>
<html>
<head>
  <!-- Standard Meta -->
<meta charset="utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1">

<link rel="icon" type="image/png" href="https://blogger.googleusercontent.com/img/a/AVvXsEiZ20DEUEXGi8r22gBsnyxEi6QApQiH4bj1WsIJgZr9cLUyuHvveIUzLJ5NSi9uFMEJewuy82i6kHnJ50zJsJ73h5bPQzp36fw_phYgPDILLQSBC504tPuKGuEqCrniUM5abLT_0ca9DVVd1enhgzI8kOP3ju-4_GrB6znax5QXNUYFt1KTMaqk6Q" />

<script src="https://semantic-ui.com/javascript/library/jquery.min.js"></script>
<script src="https://semantic-ui.com/dist/semantic.min.js"></script>
<link rel="stylesheet" type="text/css" class="ui" href="https://semantic-ui.com/dist/semantic.min.css">

<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
<link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.js"></script>


<link href="./lib/toc/toc.css" rel="stylesheet">

<title><?php echo $PAGE_TITLE; ?> - pwiki</title>
</head>
<body>

<nav class="toc">
  <ul class="main">
  </ul>
  <svg class="toc-marker" width="200" height="200" xmlns="http://www.w3.org/2000/svg">
  <path stroke="#444" stroke-width="3" fill="transparent" stroke-dasharray="0, 0, 0, 1000" stroke-linecap="round" stroke-linejoin="round" transform="translate(-0.5, -0.5)" />
  </svg>
</nav>

  <form class="ui container form" action="." method="post">

    <?php
      if (!isset($_GET["edit"]) || $_GET["edit"] !== "true") {
        ?>
    <h1><?php echo $PAGE_TITLE; ?></h1>
    
    <div class="contents"><?php echo $PAGE_CONTENT; ?></div>
    <script src="./lib/toc/toc.js"></script>
        <?php
      }
      else {
        ?>
      <div class="ui field">
        <label for="page_title">Page Title</label>
        <div class="ui input">
          <input type="text" name="page_title" id="page_title" placeholder="Title..." value="<?php echo $PAGE_TITLE; ?>" />
        </div>
      </div>

      <div class="ui field">
        <label for="page_content">Page Content</label>
        <div class="ui input">
          <textarea name="page_content" id="page_content" placeholder="Content..."><?php echo $PAGE_CONTENT; ?></textarea>
        </div>
      </div>
      <script src="./lib/summernote/summernote.js"></script>
      
        <?php
      }
    ?>


    <hr />
    
    <?php
      if (isset($_GET["edit"]) && $_GET["edit"] === "true") {

        $pwiki_password = "";
        if (isset($_COOKIE["pwiki_password"])) {
          $pwiki_password = $_COOKIE["pwiki_password"];
        }
        ?>
      <div style="text-align:center;">
        <div class="ui action input">
          <input type="password" name="password" value="<?php echo $pwiki_password ?>">
          <button type="submit" class="ui positive button">Save</button>
          <a href="./" class="ui button">Cancel</a>
        </div>
      </div>
        <?php
      }
    ?>
    <div class="ui right aligned container">
      |
      <?php
      if (!isset($_GET["edit"]) || $_GET["edit"] !== "true") {
        ?>
        <a href="?edit=true">Edit</a>
      |
        <?php
      }
      ?>
      <a href="https://github.com/pulipulichen/php-pwiki" target="pwiki">PWiki Author</a>
      |
      <a href="https://p.ecpay.com.tw/4DD5FEE" target="pwiki">Donate</a>
      |
    </div>
  </form>
  
</body>
</html>