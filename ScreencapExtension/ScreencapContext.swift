//
//  FileUtil.swift
//  ScreencapExtension
//
//  Created by Jonathan Kula on 11/4/22.
//

import Foundation
import AVKit
import Combine
import ReplayKit

class ScreencapContext {
    private static var instance_: ScreencapContext?
    private static var temporaryDirectory_: URL {
        guard let tempDir = try? FileManager.default.url(
            for: FileManager.SearchPathDirectory.cachesDirectory,
            in: FileManager.SearchPathDomainMask.allDomainsMask,
            appropriateFor: nil,
            create: true) else {
            fatalError("Could not acquire temporary directory")
        }
        return tempDir
    }
    
    private let userConfig_: UserStreamConfiguration;
    private let frameStream_: PassthroughSubject<ScreencapSampleBuffer, Error>
    private var webserver_: Webserver?
    
    
    private init(userConfig: UserStreamConfiguration) {
        userConfig_ = userConfig;
        frameStream_ = PassthroughSubject()
    }
    
    private func prepareServer(_ configurator: WebserverConfigurator) {
        webserver_ = Webserver();
        webserver_!.configure(configurator);
        do {
            try webserver_!.start()
        } catch {
            fatalError("Failed to start web server");
        }
    }
    
    static func getTemporaryDirectory() -> URL {
        return ScreencapContext.temporaryDirectory_
    }
    
    func getUserConfig() -> UserStreamConfiguration {
        return userConfig_;
    }
    
    func getFrameStream() -> PassthroughSubject<ScreencapSampleBuffer, Error> {
        return frameStream_;
    }
    
    
    static func clearTemporaryDirectory() {
        DispatchQueue.global(qos: .background).async {
            do {
                try FileManager.default.contentsOfDirectory(at: getTemporaryDirectory(), includingPropertiesForKeys: nil).forEach { url in
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch {
                        print("Failed to delete file at", url)
                    }
                }
            } catch {
                print("Failed to list directory...")
            }
        }
    }
    
    
    
    static func initialize(userConfig: UserStreamConfiguration, withServer configurator: WebserverConfigurator) -> ScreencapContext {
        if instance_ != nil {
            fatalError("Tried to initialize multiple contexts. There should only be one per invocation.")
        }
        
        instance_ = ScreencapContext(userConfig: userConfig)
        instance_!.prepareServer(configurator)
        return instance_!
    }
    
    static func instance() -> ScreencapContext {
        if instance_ == nil {
            fatalError("Tried to get instance of ScreencapContext before it was initialized")
        }
        
        return instance_!
    }
}

enum ScreencapSampleBuffer {
    case video(CMSampleBuffer)
    case deviceAudio(CMSampleBuffer)
    case micAudio(CMSampleBuffer)
}

extension CMSampleBuffer {
    func attachType(_ type: RPSampleBufferType) -> ScreencapSampleBuffer {
        switch (type) {
        case .video:
            return ScreencapSampleBuffer.video(self)
        case .audioApp:
            return ScreencapSampleBuffer.deviceAudio(self)
        case .audioMic:
            return ScreencapSampleBuffer.micAudio(self)
        @unknown default:
            fatalError("Got unknown sample type when creating ScreencapSampleBuffer")
        }
    }
}

protocol ScreencapDataReceiver : Subscriber<ScreencapSampleBuffer, Error> {
    
}
