---
layout: post
published: false
title: Uptime Monitoring
tagline: "You gotta know it"
tags: [blag, alonso, homelab, apache]
comments: true
image:
  feature: network.jpg
---



    <Location /ping>
        Satisfy Any
        Allow from all
    </Location>



VPN:

    <?php

    header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
    header("Cache-Control: post-check=0, pre-check=0", false);
    header("Pragma: no-cache");

    $c = curl_init();
    curl_setopt($c, CURLOPT_URL, "ipinfo.io/ip");
    curl_setopt($c, CURLOPT_RETURNTRANSFER, TRUE);

    $defaultIP = curl_exec($c);

    curl_setopt($c, CURLOPT_INTERFACE, 'tun0');

    $tunIP = curl_exec($c);

    if($defaultIP != $tunIP){
        http_response_code(500);
        echo "no, problem!";
    }else{
        echo "no problem";
    }

?>

Docker image:

<?php
    header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
    header("Cache-Control: post-check=0, pre-check=0", false);
    header("Pragma: no-cache");

    $cmd = "sudo docker inspect -f '{{.State.Running}}' home-assistant";

    exec($cmd, $out, $ret);
    if($ret == 0 && $out[0] == "true"){
        echo "no problem";
    }else{
        http_response_code(500);
        echo "no, problem!";
    }

?>


External host:


<?php
    header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
    header("Cache-Control: post-check=0, pre-check=0", false);
    header("Pragma: no-cache");

    $uuid = uniqid("", TRUE);
    $cmd = 'ssh -o StrictHostKeyChecking=no -i /var/www/.ssh/alonso_to_williaint williaint@192.168.1.100 "echo \"' . $uuid . '\" > /var/www/$

    exec($cmd, $out, $ret);

    if($ret == 0){
        $c = curl_init();
        curl_setopt($c, CURLOPT_URL, "192.168.1.100:80/ping.html");
        curl_setopt($c, CURLOPT_RETURNTRANSFER, TRUE);

        $ping = trim(curl_exec($c));

        if($ping == $uuid){
            echo "no problem";
        }else{
            http_response_code(500);
            echo "no, problem!";
            echo "uuid does not match, expected [" . $uuid . "], found [" . $ping . "]";
        }
    }else{
        http_response_code(500);
        echo "no, problem!";
        echo "ssh failed (exit " . $ret . ")";
    }

?>
