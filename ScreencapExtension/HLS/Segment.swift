//
//  Segment.swift
//  HLSStreamerContentUploadExtension
//
//  https://developer.apple.com/videos/play/wwdc2020/10011/ was heavily referenced
//  in the creation of this file.
//  
//  Created by @jdkula <jonathan@jdkula.dev> on 11/1/22.
//

import Foundation
import AVKit

/**
 * Packages together helpful information about a single fMP4 (m4s) segment.
 */
struct Segment {
    /// The URL the segment is located at; used to later remove that segment.
    let url: URL
    
    /// The index of this segment in sequence.
    let index: Int
    
    /// Whether or not this segment is the initialization segment, which provides additional metadata for the entire stream.
    let isInitializationSegment: Bool
    
    /// The raw ``AVAssetSegmentReport`` that gives information about this segment.
    let report: AVAssetSegmentReport?
    
    /// If this segment encodes video information, we also keep track of the track report (this allows us to figure out timing details later).
    var trackReports: [AVAssetSegmentTrackReport]?
}
