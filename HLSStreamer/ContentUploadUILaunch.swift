//
//  ContentUploadUILaunch.swift
//  HLSStreamer
//
//  Created by Jonathan Kula on 11/1/22.
//

import Foundation
import SwiftUI

struct BroadcastSetupView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> BroadcastSetupViewController {
        return BroadcastSetupViewController()
    }
    
    func updateUIViewController(_ uiViewController: BroadcastSetupViewController, context: Context) {
        // nothing
    }
    
    typealias UIViewControllerType = BroadcastSetupViewController

}
