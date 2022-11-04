//
//  SampleHandler.swift
//  HLSStreamerContentUploadExtension
//
//  https://developer.apple.com/videos/play/wwdc2018/601/ was heavily referenced
//  in the creation of this file.
//
//  Created by @jdkula <jonathan@jdkula.dev> on 10/31/22.
//

import ReplayKit
import VideoToolbox

/// Entrypoint of the extension. This is invoked/created/used when a system broadcast starts.
class SampleHandler: RPBroadcastSampleHandler {
    private var targetDir_: URL
    
    private var userConfig_: UserStreamConfiguration
    
    private var server_: HLSServer?
    private var seg_: VideoSegmenter
    private var m3u8_: M3u8Collector
    
    
    
    private func onSegment_(seg: Segment) {
        if seg.isInitializationSegment {
            m3u8_.initM3u8(config: userConfig_, segment: seg)
        } else {
            m3u8_.addSegment(segment: seg)
        }
    }
    
    private func clearTarget_() {
        do {
            try FileManager.default.contentsOfDirectory(at: targetDir_, includingPropertiesForKeys: nil).forEach { url in
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
    
    private func updateOrientation_(chunk: CMSampleBuffer) {
        if userConfig_.rotation != "auto" {
            server_?.orientation = userConfig_.rotation
            return
        }
        
        if let orientationAttachment = CMGetAttachment(chunk, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil) as? NSNumber
        {
          let orientation = CGImagePropertyOrientation(rawValue: orientationAttachment.uint32Value)
            switch (orientation) {
            case .down:
                server_?.orientation = "down"
                break
            case .up:
                server_?.orientation = "up"
                break
            case .left:
                server_?.orientation = "left"
                break
            case .right:
                server_?.orientation = "right"
                break
            default:
                server_?.orientation = "unknown"
                break
            }
        }
    }
            
    override init() {
        do {
            self.targetDir_ = try FileManager.default.url(
                for: FileManager.SearchPathDirectory.cachesDirectory,
                in: FileManager.SearchPathDomainMask.allDomainsMask,
                appropriateFor: nil,
                create: true)
        } catch {
            fatalError("Could not retrieve temporary directory to generate and serve the HLS stream")
        }
        
        // Try to load stream configuration options from disk
        userConfig_ = (try? UserStreamConfiguration.loadSync()) ?? UserStreamConfiguration();

        seg_ = VideoSegmenter(outputDir: self.targetDir_, config: userConfig_)
        m3u8_ = M3u8Collector(folderPrefix: "video")
        
        super.init()
        
        self.seg_.setOnSegment { seg in
            self.onSegment_(seg: seg)
        }
        
        clearTarget_()
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        do {
            server_ = try HLSServer(dir: self.targetDir_, m3u8: m3u8_, port: Int(userConfig_.port)!)
        } catch {
            print("Server failed...")
        }
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        server_?.stop()
        clearTarget_()
        server_ = nil
        m3u8_ = M3u8Collector(folderPrefix: "video")
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            // https://stackoverflow.com/questions/25462091/get-device-current-orientation-app-extension
            updateOrientation_(chunk: sampleBuffer)
            self.seg_.processVideo(chunk: sampleBuffer)
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            self.seg_.processAudio(chunk: sampleBuffer)
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
}
