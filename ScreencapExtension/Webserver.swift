//
//  Webserver.swift
//  ScreencapExtension
//
//  Created by Jonathan Kula on 11/4/22.
//

import Foundation
import Swifter
import AVKit
import ReplayKit

class Webserver {
    private let server_: HttpServer
        
    private var orientation_: String = "up"
    
    init() {
        self.server_ = HttpServer()
        
        server_["/orientation"] = { request in
            return HttpResponse.ok(.text(self.orientation_))
        }
        
        let _ = ScreencapContext.instance().getFrameStream().sink { err in
            // Do nothing
        } receiveValue: { buf in
            if case ScreencapSampleBuffer.video(let videoBuffer) = buf {
                self.updateOrientation_(from: videoBuffer)
            }
        }
    }
    
    deinit {
        server_.stop()
    }
    
    func start() throws {
        try server_.start(in_port_t(ScreencapContext.instance().getUserConfig().port)!)
    }
    
    private func updateOrientation_(from chunk: CMSampleBuffer) {
        let userRotation = ScreencapContext.instance().getUserConfig().rotation
        if userRotation != "auto" {
            orientation_ = userRotation
            return
        }
        
        if let orientationAttachment = CMGetAttachment(chunk, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil) as? NSNumber
        {
          let orientation = CGImagePropertyOrientation(rawValue: orientationAttachment.uint32Value)
            switch (orientation) {
            case .down:
                orientation_ = "down"
                break
            case .up:
                orientation_ = "up"
                break
            case .left:
                orientation_ = "left"
                break
            case .right:
                orientation_ = "right"
                break
            default:
                orientation_ = "unknown"
                break
            }
        }
    }
    
    func configure(_ configurator: WebserverConfigurator) {
        configurator.prepareWebserver(webserver: server_)
    }
}

protocol WebserverConfigurator {
    func prepareWebserver(webserver: HttpServer)
}
