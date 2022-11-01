//
//  Segment.swift
//  HLSStreamerContentUploadExtension
//
//  Created by Jonathan Kula on 11/1/22.
//

import Foundation
import AVKit

struct Segment {
    let index: Int
    let isInitializationSegment: Bool
    let report: AVAssetSegmentReport?
    var timingReport: AVAssetSegmentTrackReport?
}
