//
//  SampleHandler.swift
//  HLSStreamerContentUploadExtension
//
//  Created by Jonathan Kula on 10/31/22.
//

import ReplayKit
import VideoToolbox

class SampleHandler: RPBroadcastSampleHandler {
    var fm: FileManager
    var targetDir: URL
    var server: HLSServer?
    var startTimestamp: Double?
    var seg: VideoSegmenter
    var curSeq: Int
    
    var config: FMP4Configuration
            
    override init() {
        self.curSeq = 0;
        self.fm = FileManager()
        do {
            self.targetDir = try self.fm.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.allDomainsMask, appropriateFor: nil, create: true)
        } catch {
            print("TARGET DIR FAILED")
            fatalError("Target dir failed...")
        }
        
        self.config = FMP4Configuration()
        config.videoCompressionSettings["AVVideoWidthKey"] = UIScreen.main.bounds.size.height
        config.videoCompressionSettings["AVVideoHeightKey"] = UIScreen.main.bounds.size.width

        self.seg = VideoSegmenter(outputDir: self.targetDir, config: config)
        
        super.init()
        
        self.seg.setOnSegment { seg in
            self.onSegment(seg: seg)
        }
        
        try! self.fm.contentsOfDirectory(at: self.targetDir, includingPropertiesForKeys: nil).forEach { item in
            do {
                try self.fm.removeItem(at: item)
            } catch {
                print("Failed to remove item", item)
            }
        }
        
        
    }
    
    func onSegment(seg: Segment) {
        if seg.isInitializationSegment {
            server?.initM3u8(config: self.config, segment: seg)
        } else {
            server?.addSegment(segment: seg)
        }
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        do {
            server = try HLSServer(dir: self.targetDir)
            
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
        server?.stop()
        try! self.fm.contentsOfDirectory(at: self.targetDir, includingPropertiesForKeys: []).forEach { url in
            try! self.fm.removeItem(at: url)
        }
    }
    
    func noteChunk(chunk: CMSampleBuffer) {
        let ts = CMSampleBufferGetPresentationTimeStamp(chunk).seconds
        if (startTimestamp == nil) {
            startTimestamp = ts
        }
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            noteChunk(chunk: sampleBuffer)
            self.seg.processVideo(chunk: sampleBuffer)
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            noteChunk(chunk: sampleBuffer)
            self.seg.processAudio(chunk: sampleBuffer)
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
