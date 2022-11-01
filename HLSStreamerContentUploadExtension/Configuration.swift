//
//  Configuration.swift
//  HLSStreamerContentUploadExtension
//
//  Created by Jonathan Kula on 11/1/22.
//

import Foundation
import AVFoundation
import VideoToolbox

struct FMP4Configuration {
    let segmentDuration = 1
    let segmentFileNamePrefix = "seq"
    
    var audioCompressionSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        // For simplicity, hard-code a common sample rate.
        // For a production use case, modify this as necessary to get the desired results given the source content.
        AVSampleRateKey: 44_100,
        AVNumberOfChannelsKey: 2,
        AVEncoderBitRateKey: 160_000
    ]
    var videoCompressionSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        // For simplicity, assume 16:9 aspect ratio.
        // For a production use case, modify this as necessary to match the source content.
        AVVideoWidthKey: 1920,
        AVVideoHeightKey: 1080,
        AVVideoCompressionPropertiesKey: [
            kVTCompressionPropertyKey_AverageBitRate: 6_000_000,
            kVTCompressionPropertyKey_ProfileLevel: kVTProfileLevel_H264_High_5_2
        ]
    ]
    let minimumAllowableSourceFrameDuration = CMTime(value: 1, timescale: 60) // 60fps
}
