//
//  HLSConfiguration.swift
//  HLSStreamer
//
//  Provides global configuration that's shared between
//  the UI and the recording extension
//
//  Heavily referenced https://developer.apple.com/tutorials/app-dev-training/persisting-data
//
//  Created by @jdkula <jonathan@jdkula.dev> on 11/1/22.
//

import Foundation

/// Struct representing the user-configurable aspects of the application.
struct UserStreamConfiguration : Codable {
    static let kLossless = 10.5
    static let kRealtime = 0.0
    
    var port: String
    var segmentDuration: Double
    var videoBitrateMbps: Double
    var rotation: String
    
    init() {
        self.port = "8888"
        self.segmentDuration = UserStreamConfiguration.kRealtime
        self.videoBitrateMbps = UserStreamConfiguration.kLossless
        self.rotation = "auto"
    }
    
    init(port: String, segmentDuration: Double, videoBitrateMbps: Double, rotation: String) {
        self.port = port
        self.segmentDuration = segmentDuration
        self.videoBitrateMbps = videoBitrateMbps
        self.rotation = rotation
    }
    
    func withPort(_ port: String) -> UserStreamConfiguration {
        return UserStreamConfiguration(port: port, segmentDuration: self.segmentDuration, videoBitrateMbps: self.videoBitrateMbps, rotation: self.rotation)
    }
    
    func withSegmentDuration(_ segmentDuration: Double) -> UserStreamConfiguration {
        return UserStreamConfiguration(port: self.port, segmentDuration: segmentDuration, videoBitrateMbps: self.videoBitrateMbps, rotation: self.rotation)
    }
    
    func withVideoBitrateMbps(_ videoBitrateMbps: Double) -> UserStreamConfiguration {
        return UserStreamConfiguration(port: self.port, segmentDuration: self.segmentDuration, videoBitrateMbps: videoBitrateMbps, rotation: self.rotation)
    }
}

/// Observable wrapper around UserHLSConfiguration that auto-saves every time it is set.
class UserStreamConfigObserver : ObservableObject {
    @Published var config: UserStreamConfiguration = UserStreamConfiguration() {
        didSet {
            UserStreamConfiguration.save(config: config)
        }
    }
}

/**
 * Provides functions to retrieve and persist the user-facing configuration
 * (this facilitates communication between the app and the extension).
 *
 * Note that the failure mode of these functions are to return a default configuration,
 * not throw errors.
 */
extension UserStreamConfiguration {
    private static func fileURL_() throws -> URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.dev.jdkula.Wingspan.config"
        )?.appendingPathComponent("HLSStreamer.config")
    }
    
    static func loadSync() throws -> UserStreamConfiguration {
        guard let fileURL = try fileURL_() else {
            return UserStreamConfiguration()
        }
        guard let file = try? FileHandle(forReadingFrom: fileURL) else {
            return UserStreamConfiguration()
        }
        let info = try JSONDecoder().decode(UserStreamConfiguration.self, from: file.availableData)
        return info
    }
    
    static func load(onComplete: @escaping ((Result<UserStreamConfiguration, Error>) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            do {
                guard let fileURL = try fileURL_() else {
                    DispatchQueue.main.async {
                        onComplete(.success(UserStreamConfiguration()))
                    }
                    return
                }
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        onComplete(.success(UserStreamConfiguration()))
                    }
                    return
                }
                let info = try JSONDecoder().decode(UserStreamConfiguration.self, from: file.availableData)
                DispatchQueue.main.async {
                    onComplete(.success(info))
                }
            } catch {
                onComplete(.failure(error))
            }
        }
    }
    
    static func save(config: UserStreamConfiguration) {
        do {
            let data = try JSONEncoder().encode(config)
            guard let fileURL = try fileURL_() else {
                return
            }
            try data.write(to: fileURL)
        } catch {
            // Ignore
        }
    }
}
