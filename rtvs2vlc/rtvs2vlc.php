<?php
#echo 'Hello ' . htmlspecialchars($_GET["name"]) . '!';
#htmlspecialchars($_GET["c"])

function redirect($url, $statusCode = 303)
{
   header('Location: ' . $url, true, $statusCode);
   die();
}


$channel = "1";
$redirect = false;
$showinbrowser = false;
$quality = "auto";

if (isset($_GET["c"]))
    $channel = htmlspecialchars($_GET["c"]);

if (isset($_GET["r"]) and htmlspecialchars($_GET["r"]) == "true")
    $redirect = true;

if (isset($_GET["b"]) and htmlspecialchars($_GET["b"]) == "true")
    $showinbrowser = true;

if (isset($_GET["q"]))
    $quality = htmlspecialchars($_GET["q"]);


$url = "http://www.rtvs.sk/json/live5.json?c=" . $channel . "&b=chrome&p=linux&v=64&f=0&d=1";

if ((int)$channel > 6)
    $url = "http://www.rtvs.sk/json/archive5.json?id=" . $channel . "&b=chrome&p=linux&v=64&f=0&d=1";


$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true );
// This is what solved the issue (Accepting gzip encoding)
curl_setopt($ch, CURLOPT_ENCODING, "gzip,deflate");     
$response = curl_exec($ch);
curl_close($ch);
#echo $response;
#echo "HELLO\n";

$arr = json_decode($response);
$url_m3u8 = $arr[0]->{"sources"}[0]->{"file"};
$finalurl = $url_m3u8;

if($quality != "auto") {
    $strpos = strrpos($url_m3u8, "/");
    $url_base = substr($url_m3u8, 0, $strpos+1);
    $strpos = strrpos($url_m3u8, "?");
    $authpart = substr($url_m3u8, $strpos);
    $qualityindex = 5;

    if($quality == "720")
        $qualityindex = 3;
    if($quality == "1080")
        $qualityindex = 5;
    if($quality == "480")
        $qualityindex = 7;
    if($quality == "360")
        $qualityindex = 9;


    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url_m3u8);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true );
    // This is what solved the issue (Accepting gzip encoding)
    curl_setopt($ch, CURLOPT_ENCODING, "gzip,deflate");     
    $response = curl_exec($ch);

    $lines = explode("\n", $response);

    $finalurl = $url_base . $lines[$qualityindex] . $authpart;
}

if($showinbrowser) { ?>

    <head>
  <link href="https://vjs.zencdn.net/7.0.3/video-js.css" rel="stylesheet">

  <!-- If you'd like to support IE8 (for Video.js versions prior to v7) -->
  <script src="http://vjs.zencdn.net/ie8/ie8-version/videojs-ie8.min.js"></script>
</head>

<body>
  <video id="my-video" class="video-js" controls preload="auto" width="640" height="264"
  poster="MY_VIDEO_POSTER.jpg" data-setup="{}">
    <source
     src="<?php echo $finalurl; ?>"
     type="application/x-mpegURL">
    <p class="vjs-no-js">
      To view this video please enable JavaScript, and consider upgrading to a web browser that
      <a href="http://videojs.com/html5-video-support/" target="_blank">supports HTML5 video</a>
    </p>
  </video>

  <script src="https://vjs.zencdn.net/7.0.3/video.js"></script>
  <script src="videojs.hls.min.js"></script>
</body>

<?php }


elseif ($redirect)
    redirect($finalurl);
else
    echo $finalurl;

?>
