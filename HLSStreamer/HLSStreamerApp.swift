//
//  HLSStreamerApp.swift
//  HLSStreamer
//
//  Created by Jonathan Kula on 10/31/22.
//

import SwiftUI

@main
struct HLSStreamerApp: App {
    @StateObject private var config: ConfigurationObserver = ConfigurationObserver()
    
    @State private var isRecording = UIScreen.main.isCaptured
    
    var body: some Scene {
        WindowGroup {
            ContentView(config: $config.config, isRecording: $isRecording) { _ in
                
            }.onAppear {
                ConfigurationObserver.load { result in
                    switch result {
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    case .success(let cfg):
                        config.config = cfg;
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIScreen.capturedDidChangeNotification, object: nil, queue: nil) { _ in
                    isRecording = UIScreen.main.isCaptured
                }
            }
        }
    }
}
