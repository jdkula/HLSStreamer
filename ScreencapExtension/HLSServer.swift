//
//  HLSServer.swift
//  HLSStreamer
//
//  Provides a simple HTTP server that dynamically generates
//  an m3u8 playlist from an M3u8Collector, and serves mp4
//  and m4s files from the specified directory.
//
//  It also provides the current device orientation, which can
//  be used to rotate the video on the client/desktop side.
//
//  Created by @jdkula <jonathan@jdkula.dev> on 10/31/22.
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
            return HttpResponse.ok(.html(kIndexHtml))
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
