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
    let server: HttpServer
    
    var lastSegment: Segment?
    var m3u8: String = ""
    
    init(dir: URL?) throws {
        self.server = HttpServer()
        server["/"] = { request in
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
        
        server["/index.m3u8"] = { request in
            return HttpResponse.ok(.text(self.m3u8))
        }
        
        if (dir != nil) {
            server["/video/:path"] = shareFilesFromDirectory(dir!.path())
        }
        
        try server.start(8888, forceIPv4: true)
        
        print("Server started?")
    }
    
    func stop() {
        server.stop()
    }
    
    func initM3u8(config: FMP4Configuration, segment: Segment) {
        m3u8 += "#EXTM3U\n"
        + "#EXT-X-TARGETDURATION:\(config.segmentDuration)\n"
        + "#EXT-X-VERSION:7\n"
        + "#EXT-X-MEDIA-SEQUENCE:1\n"
//        + "#EXT-X-INDEPENDENT-SEGMENTS\n"
        + "#EXT-X-MAP:URI=\"video/header.mp4\"\n"
    }
    
    func addSegment(segment: Segment) {
        assert(m3u8 != "")
                
        if let previousSegmentInfo = self.lastSegment {
            let segmentDuration = segment.timingReport!.earliestPresentationTimeStamp - previousSegmentInfo.timingReport!.earliestPresentationTimeStamp
            if segmentDuration.seconds > 0 {
                m3u8 += "#EXTINF:\(String(format: "%1.5f", segmentDuration.seconds)),\t\nvideo/\(segment.index).m4s\n"
            }
        }
        
        lastSegment = segment
    }
}
