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

class HLSServer : WebserverConfigurator {
    private let m3u8_: M3u8Collector
    private let dir_: URL?
    
    init(dir: URL?, m3u8: M3u8Collector) {
        self.m3u8_ = m3u8
        self.dir_ = dir;
    }
    
    func prepareWebserver(webserver: Swifter.HttpServer) {
        webserver["/"] = { request in
            return HttpResponse.ok(.html(kIndexHtml))
        }
        
        webserver["/index.m3u8"] = { request in
            return HttpResponse.ok(.text(self.m3u8_.getM3u8()))
        }
        
        if dir_ != nil {
            webserver["/video/:path"] = shareFilesFromDirectory(dir_!.path())
        }
    }
}
