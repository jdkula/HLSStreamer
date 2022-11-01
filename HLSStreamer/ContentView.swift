//
//  ContentView.swift
//  HLSStreamer
//
//  Created by Jonathan Kula on 10/31/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Broadcast to HLSStreamer from Control Center to start the stream")
            Text("Server will start at http://<IPAD IP ADDRESS>:8888")
            Text("HLS stream at /index.m3u8")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
