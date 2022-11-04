//
//  InfoView.swift
//  HLSStreamer
//
//  Created by @jdkula <jonathan@jdkula.dev> on 11/2/22.
//

import SwiftUI

/// The portion of the home page that displays where the user can access the stream
struct InfoView: View {
    @Binding var isStreaming: Bool
    @Binding var config: UserHLSConfiguration
    
    var body: some View {
        HStack {
            Label("IP Addresses", systemImage: "wifi")
            Spacer(minLength: 40)
            VStack {
                Text(getIPAddresses().joined(separator: "\n"))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.trailing)
            }
        }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
        
        HStack {
            VStack(alignment: .leading) {
                Label("Player Webpage Address", systemImage: "globe")
                Text("(You can open this URL in your web browser to view the stream)")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 14))
            }
            Spacer(minLength: 40)

            Text(getIPInformation_(isStreaming: isStreaming)?.map { s in "http://\(s):\(config.port)/" }
                    .joined(separator: "\n") ?? "(server off)")
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color.gray)
        }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
        
        HStack {
            VStack(alignment: .leading) {
                Label("Stream Address", systemImage: "play.square.stack")
                Text("(You can open this URL in VLC or other media players supporting HLS streams)")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 14))
            }
            Spacer(minLength: 40)

            Text(getIPInformation_(isStreaming: isStreaming)?.map { s in "http://\(s):\(config.port)/index.m3u8" }.joined(separator: "\n") ?? "(server off)")
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color.gray)
        }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
    }
}
