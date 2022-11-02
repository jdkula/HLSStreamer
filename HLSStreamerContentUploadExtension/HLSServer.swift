//
//  HLSServer.swift
//  HLSStreamer
//
//  Created by Jonathan Kula on 10/31/22.
//

import Foundation
import Swifter
import AVKit

class HLSServer {
    private let server_: HttpServer
    
    private let m3u8_: M3u8Collector
    
    var orientation: String = "left"
    
    init(dir: URL?, m3u8: M3u8Collector, port: Int = 8888) throws {
        self.m3u8_ = m3u8
        self.server_ = HttpServer()
        server_["/"] = { request in
            return HttpResponse.ok(.html("""
<!DOCTYPE html>
<html>
    <head>
        <title>Playback</title>
        <style>
            html, body { margin: 0; background: transparent; }
        </style>
        <style>
            \(kCss)
        </style>
    </head>
    <body>
        <video id="hls" class="video-js" width="1080" controls muted autoplay>
            <source src="index.m3u8" type="application/x-mpegURL">
        </video>

        <script>
            \(kVideoJsHls)
        </script>
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
"""))
        }
        
        server_["/index.m3u8"] = { request in
            return HttpResponse.ok(.text(self.m3u8_.getM3u8()))
        }
        
        server_["/orientation"] = { request in
            return HttpResponse.ok(.text(self.orientation))
        }
        
        if (dir != nil) {
            server_["/video/:path"] = shareFilesFromDirectory(dir!.path())
        }
        
        try server_.start(in_port_t(port))
        
        print("Server started?")
    }
    
    func stop() {
        server_.stop()
    }
}
