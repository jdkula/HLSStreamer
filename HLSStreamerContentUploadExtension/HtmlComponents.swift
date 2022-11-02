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
        <video id="hls" class="video-js" width="1080" controls muted autoplay>
            <source src="index.m3u8" type="application/x-mpegURL">
        </video>

        <script>
            \(kVideoJs)
        </script>
        <script>
            const player = videojs('hls');
            player.play();
        </script>
        <script>
            let lastOrientation = "down";
            async function updateOrientation() {
                const orientation = await (await fetch("/orientation")).text()
                console.log("O:", orientation);
                setTimeout(updateOrientation, 1000);
            }
            setTimeout(updateOrientation, 1000);
        </script>
        <script>
            let lastErr = null;
            let lastBufferEnd = null;
            let lastBufferEndTs = null;
            async function findError() {
                if (player.readyState() === 0) {
                    if (lastErr === null) {
                        lastErr = Date.now();
                    } else if (Date.now() - lastErr > 2000) {
                        window.location.reload();
                    }
                } else {
                    lastErr = null;
                }

                if (lastBufferEnd !== player.bufferedEnd()) {
                    lastBufferEnd = player.bufferedEnd();
                    lastBufferEndTs = Date.now();
                }
                if (Date.now() - lastBufferEndTs > 10000) {
                    window.location.reload();
                }
                setTimeout(findError, 1000);
            }
            setTimeout(findError, 1000);
        </script>
    </body>
</html>
"""
