//
//  HLSStreamerApp.swift
//  HLSStreamer
//
//  Main App entrypoint
//
//  Created by @jdkula <jonathan@jdkula.dev> on 10/31/22.
//

import SwiftUI

@main
struct HLSStreamerApp: App {
    @StateObject private var config: UserStreamConfigObserver = UserStreamConfigObserver()
    
    @State private var isStreaming = UIScreen.main.isCaptured
    
    @State private var isRealtime = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(config: $config.config, isStreaming: $isStreaming, isRealtime: $isRealtime).onAppear {
                // Load config values
                UserStreamConfiguration.load { result in
                    switch result {
                    case .failure:
                        config.config = UserStreamConfiguration()
                    case .success(let cfg):
                        config.config = cfg;
                    }
                    withAnimation {
                        isRealtime = config.config.segmentDuration == UserStreamConfiguration.kRealtime
                    }
                }
                
                // Update isStreaming when we start/stop streaming
                NotificationCenter.default.addObserver(forName: UIScreen.capturedDidChangeNotification, object: nil, queue: nil) { _ in
                    isStreaming = UIScreen.main.isCaptured
                }
            }
        }
    }
}
