//
//  VideoSegment.swift
//  HLSStreamerContentUploadExtension
//
//  Created by Jonathan Kula on 10/31/22.
//

import Foundation
import AVKit

struct Segment {
    let index: Int
    let isInitializationSegment: Bool
    let report: AVAssetSegmentReport?
    var timingReport: AVAssetSegmentTrackReport?
}

class VideoSegmenter: NSObject, AVAssetWriterDelegate {
    var outputWriter: AVAssetWriter
    var videoIn: AVAssetWriterInput
    var audioIn: AVAssetWriterInput
    var finished: Bool
    
    let outputDir: URL
    
    var curSeq = 0
    
    var sessionStarted: Bool
    
    var onSegment: ((Segment) -> Void)?
    
    init(outputDir: URL, config: FMP4Configuration) {
        self.outputDir = outputDir
        self.sessionStarted = false
        self.finished = false

        self.outputWriter = AVAssetWriter(contentType: UTType(AVFileType.mp4.rawValue)!)
                
        self.videoIn = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: config.videoCompressionSettings)
        self.audioIn = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: config.audioCompressionSettings)
        
        super.init()
        
        self.outputWriter.outputFileTypeProfile = .mpeg4AppleHLS
        self.outputWriter.preferredOutputSegmentInterval = CMTime(seconds: Double(config.segmentDuration), preferredTimescale: 1)
        self.outputWriter.delegate = self
        
        self.videoIn.expectsMediaDataInRealTime = true
        self.audioIn.expectsMediaDataInRealTime = true
        
        self.outputWriter.add(self.videoIn)
        self.outputWriter.add(self.audioIn)
    }
    
    func setOnSegment(onSegment: @escaping (Segment) -> Void) {
        self.onSegment = onSegment
    }
    
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
        
        if isInitializationSegment {
            try! segmentData.write(to: self.outputDir.appending(component: "header.mp4"))
        } else {
            try! segmentData.write(to: self.outputDir.appending(component: "\(curSeq).m4s"))
        }
        
        self.onSegment?(Segment(index: curSeq, isInitializationSegment: isInitializationSegment, report: segmentReport, timingReport: segmentReport?.trackReports.first(where: {$0.mediaType == .video})))
        
        curSeq += 1
    }
    
    func processVideo(chunk: CMSampleBuffer) {
        if finished {
            return
        }
        
        if !sessionStarted {
            self.outputWriter.initialSegmentStartTime = CMSampleBufferGetPresentationTimeStamp(chunk)
            if !self.outputWriter.startWriting() {
                print("Failed?", self.outputWriter.status, self.outputWriter.error)
            }
            self.outputWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(chunk))
            sessionStarted = true
        }
        
        if videoIn.isReadyForMoreMediaData {
            videoIn.append(chunk)
        } else {
            print("Dropped data...")
        }
    }
    
    func processAudio(chunk: CMSampleBuffer) {
        if finished {
            return
        }
        
        if !sessionStarted {
            self.outputWriter.initialSegmentStartTime = CMSampleBufferGetPresentationTimeStamp(chunk)
            if !self.outputWriter.startWriting() {
                print("Failed?", self.outputWriter.status, self.outputWriter.error)
            }
            self.outputWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(chunk))
            sessionStarted = true
        }
        
        if audioIn.isReadyForMoreMediaData {
            audioIn.append(chunk)
        }
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
