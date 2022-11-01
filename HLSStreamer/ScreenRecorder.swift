//
//  ScreenRecorder.swift
//  HLSStreamer
//
//  Created by Jonathan Kula on 10/31/22.
//

import Foundation
import ReplayKit
import AVKit

class VideoChunk
{
    var outputWriter: AVAssetWriter
    var videoIn: AVAssetWriterInput
    var audioIn: AVAssetWriterInput
    var seq: Int
    init(seq: Int, targetFilename: URL) {
        self.seq = seq;
        
        let videoOutputSettings: Dictionary<String, Any> = [
                        AVVideoCodecKey : AVVideoCodecType.h264,
                        AVVideoWidthKey : UIScreen.main.bounds.size.width,
                        AVVideoHeightKey : UIScreen.main.bounds.size.height,
        //                AVVideoCompressionPropertiesKey : [
        //                    AVVideoAverageBitRateKey :425000, //96000
        //                    AVVideoMaxKeyFrameIntervalKey : 1
        //                ]
                    ];
        var channelLayout = AudioChannelLayout.init()
        channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_MPEG_5_1_D

        let audioOutputSettings: [String : Any] = [
            AVNumberOfChannelsKey: 6,
            AVFormatIDKey: kAudioFormatMPEG4AAC_HE,
            AVSampleRateKey: 44100,
            AVChannelLayoutKey: NSData(bytes: &channelLayout, length: MemoryLayout.size(ofValue: channelLayout)),
            ]

        
        self.outputWriter = try! AVAssetWriter(outputURL: targetFilename, fileType: AVFileType.mp4)
        
        self.videoIn = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        self.audioIn = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
    }
}

class ScreenRecorder
{
    var buffer: [VideoChunk]
    var fm: FileManager
    var targetDir: URL
    
    var curSeq: Int
    
    init() throws {
        self.buffer = []
        self.fm = FileManager()
        self.targetDir = try self.fm.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.allDomainsMask, appropriateFor: nil, create: true)
        self.curSeq = 0
    }
    
    func startRecording() {
        var recorder = RPScreenRecorder.shared()
        
        recorder.startCapture { (sample, bufferType, error) in
            if CMSampleBufferDataIsReady(sample) {
                
            }
        }
    }
}
