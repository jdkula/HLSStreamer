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
    var seg: VideoSegment?
        
    override init() {
        self.fm = FileManager()
        do {
            self.targetDir = try self.fm.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.allDomainsMask, appropriateFor: nil, create: true)
        } catch {
            print("TARGET DIR FAILED")
            fatalError("Target dir failed...")
        }
        super.init()
        
        try! self.fm.contentsOfDirectory(at: self.targetDir, includingPropertiesForKeys: nil).forEach { item in
            do {
                try self.fm.removeItem(at: item)
            } catch {
                print("Failed to remove item", item)
            }
        }
        
        self.seg = VideoSegment(outputDir: self.targetDir, seq: 0)
        
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
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            let ts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
            if (startTimestamp == nil) {
                startTimestamp = ts
            }
            if (ts - startTimestamp! > 10) {
                self.seg?.finish()
            }
            self.seg?.processVideo(chunk: sampleBuffer)
            print("Got video sample with timestamp ", ts-startTimestamp!, "s")
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
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
