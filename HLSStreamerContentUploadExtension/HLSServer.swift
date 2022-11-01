//
//  HLSServer.swift
//  HLSStreamer
//
//  Created by Jonathan Kula on 10/31/22.
//

import Foundation
import Swifter

class HLSServer {
    let server: HttpServer
    
    init(dir: URL?) throws {
        self.server = HttpServer()
        server["/"] = scopes {
            html {
                body {
                    p {
                        text = "HELLO FROM THE IPAD!"
                    }
                }
            }
        }
        
        if (dir != nil) {
            server["/video/:path"] = shareFilesFromDirectory(dir!.path())
        }
        
        try server.start(8888, forceIPv4: true)
        
        print("Server started?")
    }
    
    func stop() {
        server.stop()
    }
}

//class HLSServer {
//    init() {
//        let socket = CFSocketCreate(nil, AF_INET, SOCK_STREAM, IPPROTO_TCP,  CFSocketCallBackType.connectCallBack.rawValue, { (sock, cb, data, urp, umrp) in
//            // TODO
//        }, nil)
//
//        var addr = sockaddr_in(sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size), sin_family: sa_family_t(AF_INET), sin_port: Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(8888) : 8888, sin_addr: in_addr(s_addr: inet_addr("0.0.0.0")), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
//
//        let address = CFDataCreate(nil, &addr, MemoryLayout<sockaddr_in>.size)
//        CFSocketSetAddress(socket, address)
//
//        let runloop = CFSocketCreateRunLoopSource(nil, socket, 0)
//
//        CFRunLoopAddSource(CFRunLoopGetMain(), runloop, CFRunLoopMode.commonModes)
//    }
//}
