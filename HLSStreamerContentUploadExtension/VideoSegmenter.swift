//
//  VideoSegment.swift
//  HLSStreamerContentUploadExtension
//
//  https://developer.apple.com/videos/play/wwdc2020/10011/ was heavily referenced
//  in the creation of this file.
//
//  Created by @jdkula <jonathan@jdkula.dev> on 10/31/22.
//

import Foundation
import AVKit

/**
 * Provides an interface to automatically segment an input stream into
 * fMP4 segments, which are later passed to the callback defined by ``VideoSegmenter.setOnSegment``
 */
class VideoSegmenter: NSObject, AVAssetWriterDelegate {
    private var config_: UserHLSConfiguration
    
    private var outputWriter_: AVAssetWriter?
    private var videoIn_: AVAssetWriterInput?
    private var audioIn_: AVAssetWriterInput?
    private var finished_: Bool
    
    private let outputDir_: URL
    
    private var curSeq_ = 0
    
    private var sessionStarted_: Bool
    
    private var onSegment_: ((Segment) -> Void)?
    
    init(outputDir: URL, config: UserHLSConfiguration) {
        outputDir_ = outputDir
        sessionStarted_ = false
        finished_ = false
        config_ = config

        super.init()
    }
    
    // Called each time outputWriter_ produces a segment (set by ouputWriter_.delegate = self)
    @objc func assetWriter(_ writer: AVAssetWriter,
                     didOutputSegmentData segmentData: Data,
                     segmentType: AVAssetSegmentType,
                     segmentReport: AVAssetSegmentReport?) {
        let isInitializationSegment: Bool
        
        switch segmentType {
        case .initialization:
            isInitializationSegment = true
        case .separable:
            isInitializationSegment = false
        @unknown default:
            print("Skipping segment with unrecognized type \(segmentType)")
            return
        }
        
        let url = outputDir_.appending(component: isInitializationSegment ? "header.mp4" : "\(curSeq_).m4s")
        try! segmentData.write(to: url)
        
        onSegment_?(Segment(
            url: url,
            index: curSeq_,
            isInitializationSegment: isInitializationSegment,
            report: segmentReport,
            trackReports: segmentReport?.trackReports))

        
        curSeq_ += 1
    }
    
    private func initAVWriters_(chunk: CMSampleBuffer, config: FMP4Configuration) {
        outputWriter_ = AVAssetWriter(contentType: UTType(AVFileType.mp4.rawValue)!)
           
        videoIn_ = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: config.videoCompressionSettings)
        audioIn_ = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: config.audioCompressionSettings)
        
        outputWriter_!.outputFileTypeProfile = .mpeg4AppleHLS
        outputWriter_!.preferredOutputSegmentInterval = CMTime(seconds: Double(config.segmentDuration), preferredTimescale: 1)
        outputWriter_!.delegate = self
        
        videoIn_!.expectsMediaDataInRealTime = true
        audioIn_!.expectsMediaDataInRealTime = true
        
        outputWriter_!.add(videoIn_!)
        outputWriter_!.add(audioIn_!)
    }
    
    private func maybeStartSession_(chunk: CMSampleBuffer) {
        if !sessionStarted_ {
            if let formatDescription = CMSampleBufferGetFormatDescription(chunk) {
                let config = FMP4Configuration(
                    segmentDuration: config_.segmentDuration,
                    videoBitrateMbps: config_.videoBitrateMbps,
                    width: Int(formatDescription.dimensions.width),
                    height: Int(formatDescription.dimensions.height))
                initAVWriters_(chunk: chunk, config: config)
                self.outputWriter_!.initialSegmentStartTime = CMSampleBufferGetPresentationTimeStamp(chunk)
                if !self.outputWriter_!.startWriting() {
                    print("Failed?", self.outputWriter_!.status, self.outputWriter_!.error as Any)
                    fatalError("Failed to begin writing to the output file")
                }
                self.outputWriter_!.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(chunk))
                sessionStarted_ = true
            }
        }
    }

    func processVideo(chunk: CMSampleBuffer) {
        if finished_ {
            return
        }
        
        maybeStartSession_(chunk: chunk)
        
        if videoIn_ != nil && videoIn_!.isReadyForMoreMediaData {
            videoIn_!.append(chunk)
        }
    }
    
    func processAudio(chunk: CMSampleBuffer) {
        if finished_ {
            return
        }
        
        maybeStartSession_(chunk: chunk)
        
        if audioIn_ != nil && audioIn_!.isReadyForMoreMediaData {
            audioIn_!.append(chunk)
        }
    }
    
    func finish() {
        if finished_ {
            return
        }
        
        finished_ = true
        outputWriter_?.finishWriting {}
    }
    
    func setOnSegment(onSegment: @escaping (Segment) -> Void) {
        self.onSegment_ = onSegment
    }
}
