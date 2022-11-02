//
//  ContentView.swift
//  HLSStreamer
//
//  The main view for the app
//
//  Created by @jdkula <jonathan@jdkula.dev> on 10/31/22.
//

import SwiftUI
import ReplayKit
import Combine

struct ContentView: View {
    @Binding var config: UserHLSConfiguration
    @Binding var isStreaming: Bool
    
    private func getIPInformation_() -> String {
        if !isStreaming {
            return "(server off)"
        }
        
        let addresses = getIPAddresses()
        let ipv4 = addresses.first(where: {s in
            s.contains(".") && !s.starts(with: "169.")
        })
        let ipv6 = getIPAddresses().first(where: {s in
            s.contains(":") && !s.starts(with: "fe80::")
        })
        let fallback = "<IPAD IP ADDRESS>"
        
        return ipv4 ?? ipv6 ?? fallback
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, content: {
                
                // <== Title ==>
                Group {
                    HStack {}.padding()
                    
                    Text("HLSStreamer").font(.system(size: 60, weight: .bold)).padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 0))
                }
                
                // <== Info Section ==>
                Group {
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
                        
                        Text(getIPInformation_())
                    }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
                    
                }
                
                // <== Start Recording Button ==>
                if #available(iOS 15.0, *) {
                    Group {
                        HStack {}.padding()
                        
                        VStack {
                            BroadcastSetupView(isStreaming: $isStreaming).frame(width: 400, height: 105, alignment: .center)
                        }.frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                // <== Settings ==>
                Group {
                    
                    Text("Settings").font(.system(size: 45, weight: .thin))
                    
                    HStack {
                        Label("Port Number", systemImage: "number.circle")
                        Spacer()
                        TextField("", text: $config.port).textFieldStyle(.roundedBorder).keyboardType(.numberPad).frame(maxWidth: 120).multilineTextAlignment(.trailing).onReceive(Just(config.port)) { newValue in
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
                        Label("Segment Duration", systemImage: "timelapse")
                        Spacer()
                        Slider(value: $config.segmentDuration, in: 0.5...10, step: 0.5).frame(maxWidth: 250)
                        
                        Text(String(format: "%.1f", config.segmentDuration)).frame(width: 80, alignment: .trailing)
                    }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
                    
                    
                    HStack {
                        Label("Video Bitrate (Mbps)", systemImage: "calendar.day.timeline.left")
                        Spacer()
                        Slider(value: $config.videoBitrateMbps, in: 0.5...10, step: 0.5).frame(maxWidth: 250)
                        Text(String(format: "%.1f", config.videoBitrateMbps)).frame(width: 80, alignment: .trailing)
                        
                    }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
                    
                    HStack {
                        Label("Reset Values", systemImage: "arrow.clockwise")
                        Spacer()
                        Button("Tap to Reset") {
                            config = UserHLSConfiguration()
                        }
                    }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)
                    
                }
            }).padding()
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(config: .constant(UserHLSConfiguration()), isStreaming: .constant(false))
    }
}

// https://stackoverflow.com/questions/65736518/how-do-i-create-a-slider-in-swiftui-for-an-int-type-property
struct IntDoubleBinding {
    let intValue : Binding<Int>
    
    let doubleValue : Binding<Double>
    
    init(_ intValue : Binding<Int>) {
        self.intValue = intValue
        
        self.doubleValue = Binding<Double>(get: {
            return Double(intValue.wrappedValue)
        }, set: {
            intValue.wrappedValue = Int($0)
        })
    }
}
