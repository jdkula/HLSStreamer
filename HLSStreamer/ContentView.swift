//
//  ContentView.swift
//  HLSStreamer
//
//  Created by Jonathan Kula on 10/31/22.
//

import SwiftUI
import ReplayKit
import Combine

struct ContentView: View {
    @State var port = "8888";
    @State var segmentDuration: Double = 1;
    @State var videoBitrateMbps: Double = 6;

    
    var body: some View {
        VStack(alignment: .leading, content: {
            
            Text("HLSStreamer").font(.system(size: 60, weight: .bold)).padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 0))
            
            HStack {
                Label("IP Addresses", systemImage: "wifi")
                Spacer()
                VStack {
                    ForEach(getIPAddresses(), id: \.self) {
                        Text($0).foregroundColor(Color.gray)
                    }
                }
            }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
            
            HStack {
                Label("Page Address", systemImage: "globe")
                Spacer()
                Text("http://\(getIPAddresses().first(where: {s in s.contains(".")}) ?? "<IPAD IP ADDRESS>"):\(port)/")
            }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
            
            HStack {}.padding()
            
            VStack {
                if #available(iOS 15.0, *) {
                    BroadcastSetupView().frame(width: 400, height: 105, alignment: .center)
                } else {
                    Button("Start Recording") {
                        print("boop")
                    }.foregroundColor(Color.red).buttonStyle(.automatic)
                }
            }.frame(maxWidth: .infinity, alignment: .center)
            
            HStack {}.padding()
            
            Text("Settings").font(.system(size: 45, weight: .thin))

            HStack {
                Label("Port Number", systemImage: "number.circle")
                Spacer()
                TextField("", text: $port).textFieldStyle(.roundedBorder).keyboardType(.numberPad).frame(maxWidth: 120).multilineTextAlignment(.trailing).onReceive(Just(port)) { newValue in
                    let n = Int(newValue.filter { $0.isNumber })
                    if (n == nil) {
                        self.port = ""
                        return
                    } else if n! > 65_535 {
                        self.port = "65535"
                    } else {
                        self.port = "\(n!)"
                    }
                }
            }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
            
            HStack {
                Label("Segment Duration", systemImage: "timelapse")
                Spacer()
                Slider(value: $segmentDuration, in: 0.05...10).frame(maxWidth: 250)
                
                Text(String(format: "%.3f", segmentDuration)).frame(width: 80, alignment: .trailing)
            }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
            
            
            HStack {
                Label("Video Bitrate (MB/s)", systemImage: "calendar.day.timeline.left")
                Spacer()
                Slider(value: $videoBitrateMbps, in: 0.05...10).frame(maxWidth: 250)
                Text(String(format: "%.3f", videoBitrateMbps)).frame(width: 80, alignment: .trailing)

            }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)

            
        }).padding()
        
        Spacer()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
