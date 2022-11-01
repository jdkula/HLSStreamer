//
//  VideoSegment.swift
//  HLSStreamerContentUploadExtension
//
//  Created by Jonathan Kula on 10/31/22.
//

import Foundation
import AVKit

class VideoSegment {
    var outputWriter: AVAssetWriter
    var videoIn: AVAssetWriterInput
    var audioIn: AVAssetWriterInput
    var seq: Int
    var finished: Bool
    
    var sessionStarted: Bool
    
    init(outputDir: URL, seq: Int) {
        self.sessionStarted = false
        self.finished = false
        self.seq = seq
        let outputUrl = outputDir.appending(component: "\(seq).mp4")
        
        let videoOutputSettings: Dictionary<String, Any> = [
                        AVVideoCodecKey : AVVideoCodecType.h264,
                        AVVideoWidthKey : UIScreen.main.bounds.size.height,
                        AVVideoHeightKey : UIScreen.main.bounds.size.width,
        //                AVVideoCompressionPropertiesKey : [
        //                    AVVideoAverageBitRateKey :425000, //96000
        //                    AVVideoMaxKeyFrameIntervalKey : 1
        //                ]
                    ];
        var channelLayout = AudioChannelLayout.init()
        channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo

        let audioOutputSettings: [String : Any] = [
            AVNumberOfChannelsKey: 2,
            AVFormatIDKey: kAudioFormatMPEG4AAC_HE,
            AVSampleRateKey: 44100,
            AVChannelLayoutKey: NSData(bytes: &channelLayout, length: MemoryLayout.size(ofValue: channelLayout)),
        ]

        
        self.outputWriter = try! AVAssetWriter(outputURL: outputUrl, fileType: AVFileType.mp4)
        
        self.videoIn = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        self.audioIn = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        
        
        self.videoIn.expectsMediaDataInRealTime = true
        self.audioIn.expectsMediaDataInRealTime = true
        
        self.outputWriter.add(self.videoIn)
        self.outputWriter.add(self.audioIn)
        
        if !self.outputWriter.startWriting() {
            print("Failed?", self.outputWriter.status, self.outputWriter.error)
        }
    }
    
    func processVideo(chunk: CMSampleBuffer) {
        if finished {
            return
        }
        
        if !sessionStarted {
            self.outputWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(chunk))
        }
        
        videoIn.append(chunk);
    }
    
    func finish() {
        if finished {
            return
        }
        
        finished = true
        outputWriter.finishWriting {
            print("Done?")
        }
    }
}
