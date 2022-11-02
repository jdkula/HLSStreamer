//
//  M3u8Collector.swift
//  HLSStreamerContentUploadExtension
//
//  Created by Jonathan Kula on 11/1/22.
//

import Foundation
import AVKit

class M3u8Collector {
    private var lastSegment_: Segment?
    private var m3u8_ = ""
    
    private let folderPrefix_: String
    
    init(folderPrefix: String) {
        folderPrefix_ = folderPrefix;
    }
    
    func initM3u8(config: FMP4Configuration, segment: Segment) {
        m3u8_ += "#EXTM3U\n"
        + "#EXT-X-TARGETDURATION:\(config.segmentDuration)\n"
        + "#EXT-X-VERSION:7\n"
        + "#EXT-X-MEDIA-SEQUENCE:1\n"
        + "#EXT-X-MAP:URI=\"\(folderPrefix_)/header.mp4\"\n"
    }
    
    func addSegment(segment: Segment) {
        assert(m3u8_ != "")
                
        if let previousSegmentInfo = self.lastSegment_ {
            let segmentDuration = segment.timingReport!.earliestPresentationTimeStamp.seconds - previousSegmentInfo.timingReport!.earliestPresentationTimeStamp.seconds
            if segmentDuration > 0 {
                m3u8_ += "#EXTINF:\(String(format: "%1.5f", segmentDuration)),\t\n\(folderPrefix_)/\(segment.index).m4s\n"
            }
        }
        
        lastSegment_ = segment
    }
    
    func getM3u8() -> String {
        return m3u8_
    }
}
