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
    @StateObject private var config: UserHLSConfigObserver = UserHLSConfigObserver()
    
    @State private var isStreaming = UIScreen.main.isCaptured
    
    var body: some Scene {
        WindowGroup {
            ContentView(config: $config.config, isStreaming: $isStreaming).onAppear {
                // Load config values
                UserHLSConfiguration.load { result in
                    switch result {
                    case .failure:
                        config.config = UserHLSConfiguration()
                    case .success(let cfg):
                        config.config = cfg;
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
