<?php
$url = "https://api.github.com/repos/xLightsSequencer/xLights/releases/latest";
$client = curl_init($url);
curl_setopt($client,CURLOPT_RETURNTRANSFER,true);
curl_setopt($client,CURLOPT_USERAGENT, "xLights linux auto version checker");
$response = curl_exec($client);
 
$result = json_decode($response);
$fname = preg_replace('/(.*)\/(xLights-.*AppImage)/', '$2', $result->assets[0]->browser_download_url);
$fdate = preg_replace("/(.*)-(.*)-(.*)T.*/",'$1/$2/$3',$result->assets[0]->created_at);
print $fname . " - " . $fdate;
?>
