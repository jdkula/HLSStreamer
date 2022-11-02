//
//  ContentUploadUILaunch.swift
//  HLSStreamer
//
//  Created by Jonathan Kula on 11/1/22.
//

import Foundation
import SwiftUI

struct BroadcastSetupView: UIViewControllerRepresentable {
    @Binding var isRecording: Bool
    
    func makeUIViewController(context: Context) -> BroadcastSetupViewController {
        let vc = BroadcastSetupViewController()
        vc.setRecording(isRecording);
        return vc;
    }
    
    func updateUIViewController(_ uiViewController: BroadcastSetupViewController, context: Context) {
        uiViewController.setRecording(isRecording);
    }
    
    typealias UIViewControllerType = BroadcastSetupViewController

}
