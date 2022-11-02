//
//  SampleHandler.swift
//  HLSStreamerContentUploadExtension
//
//  Created by Jonathan Kula on 10/31/22.
//

import ReplayKit
import VideoToolbox

class SampleHandler: RPBroadcastSampleHandler {
    private var targetDir_: URL
    
    private var config_: FMP4Configuration
    private var savedConfig_: ConfigurationObj
    
    private var server_: HLSServer?
    private var seg_: VideoSegmenter
    private var m3u8_: M3u8Collector
            
    override init() {
        do {
            self.targetDir_ = try FileManager.default.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.allDomainsMask, appropriateFor: nil, create: true)
        } catch {
            print("TARGET DIR FAILED")
            fatalError("Target dir failed...")
        }
        
        savedConfig_ = (try? ConfigurationObserver.loadSync()) ?? ConfigurationObj();
        
        print("Got config", savedConfig_)
        
        self.config_ = FMP4Configuration(
            segmentDuration: savedConfig_.segmentDuration,
            videoBitrateMbps: savedConfig_.videoBitrateMbps,
            fps: savedConfig_.fps
        )
        

        self.seg_ = VideoSegmenter(outputDir: self.targetDir_, config: config_)
        self.m3u8_ = M3u8Collector(folderPrefix: "video")
        
        super.init()
        
        self.seg_.setOnSegment { seg in
            self.onSegment(seg: seg)
        }
        
        clearTarget_()
    }
    
    func onSegment(seg: Segment) {
        if seg.isInitializationSegment {
            m3u8_.initM3u8(config: config_, segment: seg)
        } else {
            m3u8_.addSegment(segment: seg)
        }
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        do {
            server_ = try HLSServer(dir: self.targetDir_, m3u8: m3u8_, port: Int(savedConfig_.port)!)
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
    
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            // https://stackoverflow.com/questions/25462091/get-device-current-orientation-app-extension
            if let orientationAttachment = CMGetAttachment(sampleBuffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil) as? NSNumber
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
