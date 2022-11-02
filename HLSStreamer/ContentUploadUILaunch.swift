//
//  ContentUploadUILaunch.swift
//  HLSStreamer
//
//  Created by @jdkula <jonathan@jdkula.dev> on 11/1/22.
//

import Foundation
import SwiftUI

/// Allows ``BroadcastSetupViewController`` to be used in SwiftUI
struct BroadcastSetupView: UIViewControllerRepresentable {
    @Binding var isStreaming: Bool
    
    func makeUIViewController(context: Context) -> BroadcastSetupViewController {
        let vc = BroadcastSetupViewController()
        vc.setStreaming(isStreaming);
        return vc;
    }
    
    func updateUIViewController(_ uiViewController: BroadcastSetupViewController, context: Context) {
        uiViewController.setStreaming(isStreaming);
    }
    
    typealias UIViewControllerType = BroadcastSetupViewController

}
