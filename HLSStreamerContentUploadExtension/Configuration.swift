//
//  Configuration.swift
//  HLSStreamerContentUploadExtension
//
//  Created by Jonathan Kula on 11/1/22.
//

import Foundation
import AVFoundation
import VideoToolbox
import UIKit

struct FMP4Configuration {
    var segmentDuration: Double
    var segmentFileNamePrefix = "seq"
    
    var audioCompressionSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        // For simplicity, hard-code a common sample rate.
        // For a production use case, modify this as necessary to get the desired results given the source content.
        AVSampleRateKey: 44_100,
        AVNumberOfChannelsKey: 2,
        AVEncoderBitRateKey: 160_000
    ]
    var videoCompressionSettings: [String: Any]
    var minimumAllowableSourceFrameDuration: CMTime
    
    
    init(segmentDuration: Double = 1, videoBitrateMbps: Double = 6, fps: Int = 60, width: Int = Int(UIScreen.main.bounds.size.height), height: Int = Int(UIScreen.main.bounds.size.width)) {
        self.segmentDuration = segmentDuration
        self.videoCompressionSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            // For simplicity, assume 16:9 aspect ratio.
            // For a production use case, modify this as necessary to match the source content.
            AVVideoWidthKey: width,
            AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [
                kVTCompressionPropertyKey_AverageBitRate: videoBitrateMbps * 1_000_000,
                kVTCompressionPropertyKey_ProfileLevel: kVTProfileLevel_H264_Main_5_2,
                kVTCompressionPropertyKey_Quality: 1,
            ]
        ]
        self.minimumAllowableSourceFrameDuration = CMTime(value: 1, timescale: CMTimeScale(fps))
    }
}
