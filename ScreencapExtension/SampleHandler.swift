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
    override init() {
        super.init()
        // Try to load stream configuration options from disk
        let config = (try? UserStreamConfiguration.loadSync()) ?? UserStreamConfiguration();
        let dir = ScreencapContext.getTemporaryDirectory()
        
        let segmenter = HLSVideoSegmenter(outputDir: dir, config: config)
        let m3u8collector = M3u8Collector(urlPrefix: "video")
        let server = HLSServer(dir: dir, m3u8: m3u8collector)
        
        segmenter.receive(subscriber: m3u8collector)
        
        ScreencapContext.initialize(userConfig: config, withServer: server).getFrameStream().receive(subscriber: segmenter)
        
        ScreencapContext.clearTemporaryDirectory()
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        ScreencapContext.clearTemporaryDirectory()
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        ScreencapContext.instance().getFrameStream().send(sampleBuffer.attachType(sampleBufferType))
    }
}
