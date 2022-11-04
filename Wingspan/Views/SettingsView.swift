//
//  SettingsView.swift
//  HLSStreamer
//
//  Created by @jdkula <jonathan@jdkula.dev> on 11/2/22.
//

import SwiftUI
import Combine

/// The portion of the home page that allows the user to configure the settings used by the stream
struct SettingsView: View {
    @Binding var isStreaming: Bool
    @Binding var config: UserHLSConfiguration
    
    var body: some View {
        Text("Settings").font(.system(size: 45, weight: .thin))
        
        HStack {
            VStack(alignment: .leading) {
                Label("Port Number", systemImage: "number.circle")
                Text("(Configures which port the HTTP server listens on)")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 14))
            }
            Spacer(minLength: 40)

            TextField("", text: $config.port)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(maxWidth: 120)
                .multilineTextAlignment(.trailing)
                .onReceive(Just(config.port)) { newValue in
                    let n = Int(newValue.filter { $0.isNumber })
                    
                    if (newValue == config.port) {
                        return
                    } else if (n == nil) {
                        config = config.withPort("")
                    } else if n! > 65_535 {
                        config = config.withPort("65535")
                    } else {
                        config = config.withPort("\(n!)")
                    }
                }
        }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
        
        HStack {
            VStack(alignment: .leading) {
                Label("Segment Duration", systemImage: "timelapse")
                Text("(Configures the length of each HLS segment; higher values make streams more stable, but give them a longer delay, and vice versa)")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 14))
            }
            Spacer(minLength: 40)

            Slider(value: $config.segmentDuration, in: 1...10, step: 1).frame(maxWidth: 250)
            
            Text(String(format: "%.0f", config.segmentDuration) + " s")
                .frame(width: 80, alignment: .trailing)
        }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
        
        
        HStack {
            VStack(alignment: .leading) {
                Label("Video Bitrate (Mbps)", systemImage: "calendar.day.timeline.left")
                Text("(Configures the average bitrate to request of the output video. \"Lossless\" turns off video compression.)")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 14))
            }

            Spacer(minLength: 40)
            Slider(value: $config.videoBitrateMbps, in: 0.5...10.5, step: 0.5).frame(maxWidth: 250)
            Text(config.videoBitrateMbps == UserHLSConfiguration.kLossless ? "Lossless" : (String(format: "%.1f", config.videoBitrateMbps) + " Mbps"))
                .frame(width: 80, alignment: .trailing)
            
        }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
        
        HStack {
            VStack(alignment: .leading) {
                Label("Video Rotation", systemImage: "lock.rotation")
                Text("(Restart the stream for changes to take effect.)")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 14))
            }

            Spacer(minLength: 40)
            Picker("", selection: $config.rotation) {
                Text("Auto").tag("auto")
                Text("0°").tag("up")
                Text("90°").tag("left")
                Text("180°").tag("down")
                Text("270°").tag("right")
            }.pickerStyle(.segmented).frame(maxWidth: 400)
            
        }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)

        
        HStack {
            Label("Reset Values", systemImage: "arrow.clockwise")
            Spacer()
            Button("Tap to Reset") {
                config = UserHLSConfiguration()
            }
        }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)

    }
}
