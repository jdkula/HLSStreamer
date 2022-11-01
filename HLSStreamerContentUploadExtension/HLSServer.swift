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
    
    init(dir: URL?, m3u8: M3u8Collector) throws {
        self.m3u8_ = m3u8
        self.server_ = HttpServer()
        server_["/"] = { request in
            return HttpResponse.ok(.html("""
<!DOCTYPE html>
<html>
    <head>
        <title>Playback</title>
        <style>
            body { margin: 0; }
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
    </body>
</html>
"""))
        }
        
        server_["/index.m3u8"] = { request in
            return HttpResponse.ok(.text(self.m3u8_.getM3u8()))
        }
        
        if (dir != nil) {
            server_["/video/:path"] = shareFilesFromDirectory(dir!.path())
        }
        
        try server_.start(8888, forceIPv4: true)
        
        print("Server started?")
    }
    
    func stop() {
        server_.stop()
    }
}
