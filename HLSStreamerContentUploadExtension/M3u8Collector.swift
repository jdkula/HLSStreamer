//
//  M3u8Collector.swift
//  HLSStreamerContentUploadExtension
//
//  Created by Jonathan Kula on 11/1/22.
//

import Foundation
import AVKit

class M3u8Collector {
    private var headerSegment_: Segment? = nil
    private var segments_: [Segment] = []
    private var segmentDuration_: Double = 0.0
    
    private var seqNo_: Int = 1;
    private var segmentsToKeep_: Int = 0
    
    private let folderPrefix_: String
    
    init(folderPrefix: String) {
        folderPrefix_ = folderPrefix;
    }
    
    private func getHeader_() -> String {
        return "#EXTM3U\n"
        + "#EXT-X-TARGETDURATION:\(segmentDuration_)\n"
        + "#EXT-X-VERSION:7\n"
        + "#EXT-X-MEDIA-SEQUENCE:\(seqNo_)\n"
        + "#EXT-X-MAP:URI=\"\(folderPrefix_)/header.mp4\"\n"
    }
    
    private func getContent_() -> String {
        var lastSegment: Segment?
        
        var m3u8 = ""
        
        for segment in segments_ {
            if let previousSegmentInfo = lastSegment {
                let segmentDuration = segment.timingReport!.earliestPresentationTimeStamp.seconds - previousSegmentInfo.timingReport!.earliestPresentationTimeStamp.seconds
                if segmentDuration > 0 {
                    m3u8 += "#EXTINF:\(String(format: "%1.5f", segmentDuration)),\t\n\(folderPrefix_)/\(segment.index).m4s\n"
                }
            }
            lastSegment = segment
        }
        
        return m3u8
    }
    
    private func maybePruneSegments_() {
        while segments_.count > segmentsToKeep_ {
            let seg = segments_.remove(at: 0)
            seqNo_ += 1;
            DispatchQueue.global(qos: .background).async {
                do {
                    try FileManager.default.removeItem(at: seg.url)
                } catch {
                    print("Got error removing item at", seg.url)
                }
            }
        }
    }
    
    func initM3u8(config: FMP4Configuration, segment: Segment) {
        segmentsToKeep_ = max(10, Int(60 / config.segmentDuration))
        seqNo_ = 1;
        segments_ = [];
        headerSegment_ = segment;
        segmentDuration_ = config.segmentDuration
    }
    
    func addSegment(segment: Segment) {
        segments_.append(segment);
        maybePruneSegments_();
    }
    
    func getM3u8() -> String {
        return getHeader_() + getContent_()
    }
}
