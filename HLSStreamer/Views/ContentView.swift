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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, content: {
                
                // <== Title ==>
                Group {
                    HStack {}.padding()
                    
                    Text("HLSStreamer").font(.system(size: 60, weight: .bold)).padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 0))
                }
                
                // <== Info Section ==>
                InfoView(isStreaming: $isStreaming, config: $config)
                
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
                SettingsView(isStreaming: $isStreaming, config: $config)
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
