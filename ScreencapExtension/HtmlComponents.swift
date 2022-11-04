//
//  HtmlLibraryComponents.swift
//  HLSStreamerContentUploadExtension
//
//  Provides HTML/etc that is used by the internal HTTP server.
//
//  Created by @jdkula <jonathan@jdkula.dev> on 11/2/22.
//

let kIndexHtml = """
<!DOCTYPE html>
<html>
    <head>
        <title>Playback</title>
        <style>
            html, body { margin: 0; background: transparent; }
        </style>
        <style>
            \(kVideoJsCss)
        </style>
    </head>
    <body>
        <video id="hls" class="video-js" muted autoplay>
            <source src="index.m3u8" type="application/x-mpegURL">
        </video>

        <script>
            \(kVideoJs)
        </script>
        <script>
            const player = videojs('hls', {"controls": true, "autoplay": "muted", "fluid": true, "liveui": true});
            player.play();
        </script>
        <script>
            let lastOrientation = "up";
            function getAspectRatio() {
              return document.querySelector("video").videoHeight / document.querySelector("video").videoWidth * 100;
            }
            function setRotation(rot) {
              let multiplier = Math.floor(Math.abs(Math.sin(rot * Math.PI / 180)));

              document.querySelector("video").style.transform = `rotate(${rot}deg) scale(${getAspectRatio() * multiplier || 100}%)`;
            }
            async function updateOrientation() {
                const orientation = await (await fetch("/orientation")).text()
                switch (orientation) {
                  case "up":
                    setRotation(0);
                    break;
                  case "down":
                    setRotation(180);
                    break;
                  case "left":
                    setRotation(90);
                    break;
                  case "right":
                    setRotation(270);
                    break;
                }
                setTimeout(updateOrientation, 1000);
            }
            setTimeout(updateOrientation, 1000);
        </script>
    </body>
</html>
"""
