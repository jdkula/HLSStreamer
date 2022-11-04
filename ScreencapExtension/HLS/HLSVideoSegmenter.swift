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
import Combine

/**
 * Provides an interface to automatically segment an input stream into
 * fMP4 segments, which are later passed to the callback defined by ``VideoSegmenter.setOnSegment``
 */
class HLSVideoSegmenter: NSObject, AVAssetWriterDelegate, ScreencapDataReceiver, Subject {
    private let subject_ : PassthroughSubject<Segment, Error>
    func send(_ value: Segment) {
        subject_.send(value)
    }
    func receive<S>(subscriber: S) where S : Subscriber, Error == S.Failure, Segment == S.Input {
        subject_.receive(subscriber: subscriber)
    }
    func send(completion: Subscribers.Completion<Error>) {
        subject_.send(completion: completion)
    }
    
    func send(subscription: Subscription) {
        subject_.send(subscription: subscription)
    }
    typealias Output = Segment
    typealias Failure = Error
    
    private var subscription_: Subscription?
    func receive(subscription: Subscription) {
        subscription_ = subscription
        subscription.request(.unlimited)
    }
    
    func receive(_ input: ScreencapSampleBuffer) -> Subscribers.Demand {
        switch (input) {
        case .video(let buf):
            processVideo(chunk: buf)
            break
        case .deviceAudio(let buf):
            processAudio(chunk: buf)
            break
        default:
            break
        }
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Error>) {
        // Do nothing
    }
    
    private var config_: UserStreamConfiguration
    
    private var outputWriter_: AVAssetWriter?
    private var videoIn_: AVAssetWriterInput?
    private var audioIn_: AVAssetWriterInput?
    private var finished_: Bool
    
    private let outputDir_: URL
    
    private var curSeq_ = 0
    
    private var sessionStarted_: Bool
        
    init(outputDir: URL, config: UserStreamConfiguration) {
        outputDir_ = outputDir
        sessionStarted_ = false
        finished_ = false
        config_ = config
        subject_ = PassthroughSubject()

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
            Swift.print("Skipping segment with unrecognized type \(segmentType)")
            return
        }
        
        let url = outputDir_.appending(component: isInitializationSegment ? "header.mp4" : "\(curSeq_).m4s")
        try! segmentData.write(to: url)
        
        send(Segment(
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
        outputWriter_!.initialSegmentStartTime = CMSampleBufferGetPresentationTimeStamp(chunk)
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
                if !self.outputWriter_!.startWriting() {
                    fatalError("Failed to begin writing to the output file")
                }
                self.outputWriter_!.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(chunk))
                sessionStarted_ = true
            }
        }
    }

    private func processVideo(chunk: CMSampleBuffer) {
        if finished_ {
            return
        }
        
        maybeStartSession_(chunk: chunk)
        
        if videoIn_ != nil && videoIn_!.isReadyForMoreMediaData {
            videoIn_!.append(chunk)
        }
    }
    
    private func processAudio(chunk: CMSampleBuffer) {
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
}

protocol SegmentDataReceiver : Subscriber<Segment, Error> {
    
}
