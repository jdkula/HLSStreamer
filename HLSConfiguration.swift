//
//  Configuration.swift
//  HLSStreamer
//
//  Created by Jonathan Kula on 11/1/22.
//

import Foundation

struct ConfigurationObj : Codable {
    var port: String
    var segmentDuration: Double
    var videoBitrateMbps: Double
    var fps: Int
    
    init() {
        self.port = "8888"
        self.segmentDuration = 1
        self.videoBitrateMbps = 6
        self.fps = 60
    }
    
    init(port: String, segmentDuration: Double, videoBitrateMbps: Double, fps: Int=60) {
        self.port = port
        self.segmentDuration = segmentDuration
        self.videoBitrateMbps = videoBitrateMbps
        self.fps = 60
    }
    
    func withPort(_ port: String) -> ConfigurationObj {
        return ConfigurationObj(port: port, segmentDuration: self.segmentDuration, videoBitrateMbps: self.videoBitrateMbps, fps: self.fps)
    }
    
    func withSegmentDuration(_ segmentDuration: Double) -> ConfigurationObj {
        return ConfigurationObj(port: self.port, segmentDuration: segmentDuration, videoBitrateMbps: self.videoBitrateMbps, fps: self.fps)
    }
    
    func withVideoBitrateMbps(_ videoBitrateMbps: Double) -> ConfigurationObj {
        return ConfigurationObj(port: self.port, segmentDuration: self.segmentDuration, videoBitrateMbps: videoBitrateMbps, fps: self.fps)
    }
    
    func withFps(_ fps: Int) -> ConfigurationObj {
        return ConfigurationObj(port: self.port, segmentDuration: self.segmentDuration, videoBitrateMbps: self.videoBitrateMbps, fps: fps)
    }
}

class ConfigurationObserver : ObservableObject {
    @Published var config: ConfigurationObj = ConfigurationObj() {
        didSet {
            ConfigurationObserver.save(config: config) {_ in }
        }
    }
    
    private static func fileURL_() throws -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dev.jdkula.HLSStreamer.config")?.appendingPathComponent("HLSStreamer.config")
    }
    
    static func loadSync() throws -> ConfigurationObj {
        guard let fileURL = try fileURL_() else {
            return ConfigurationObj()
        }
        guard let file = try? FileHandle(forReadingFrom: fileURL) else {
            return ConfigurationObj()
        }
        let info = try JSONDecoder().decode(ConfigurationObj.self, from: file.availableData)
        return info
    }
    
    static func load(onComplete: @escaping ((Result<ConfigurationObj, Error>) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            do {
                guard let fileURL = try fileURL_() else {
                    DispatchQueue.main.async {
                        onComplete(.success(ConfigurationObj()))
                    }
                    return
                }
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        onComplete(.success(ConfigurationObj()))
                    }
                    return
                }
                let info = try JSONDecoder().decode(ConfigurationObj.self, from: file.availableData)
                DispatchQueue.main.async {
                    onComplete(.success(info))
                }
                                   
                                   
            } catch {
                onComplete(.failure(error))
            }
        }
    }
    
    static func save(config: ConfigurationObj, onComplete: @escaping (Result<ConfigurationObj, Error>)->Void) {
        do {
            let data = try JSONEncoder().encode(config)
            guard let fileURL = try fileURL_() else {
                DispatchQueue.main.async {
                    onComplete(.success(ConfigurationObj()))
                }
                return
            }
            try data.write(to: fileURL)
            DispatchQueue.main.async {
                onComplete(.success(config))
            }
        } catch {
            DispatchQueue.main.async {
                onComplete(.failure(error))
            }
        }
    }
}
