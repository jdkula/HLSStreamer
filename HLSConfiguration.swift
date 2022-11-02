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
struct UserHLSConfiguration : Codable {
    var port: String
    var segmentDuration: Double
    var videoBitrateMbps: Double
    
    init() {
        self.port = "8888"
        self.segmentDuration = 6
        self.videoBitrateMbps = 6
    }
    
    init(port: String, segmentDuration: Double, videoBitrateMbps: Double) {
        self.port = port
        self.segmentDuration = segmentDuration
        self.videoBitrateMbps = videoBitrateMbps
    }
    
    func withPort(_ port: String) -> UserHLSConfiguration {
        return UserHLSConfiguration(port: port, segmentDuration: self.segmentDuration, videoBitrateMbps: self.videoBitrateMbps)
    }
    
    func withSegmentDuration(_ segmentDuration: Double) -> UserHLSConfiguration {
        return UserHLSConfiguration(port: self.port, segmentDuration: segmentDuration, videoBitrateMbps: self.videoBitrateMbps)
    }
    
    func withVideoBitrateMbps(_ videoBitrateMbps: Double) -> UserHLSConfiguration {
        return UserHLSConfiguration(port: self.port, segmentDuration: self.segmentDuration, videoBitrateMbps: videoBitrateMbps)
    }
}

/// Observable wrapper around UserHLSConfiguration that auto-saves every time it is set.
class UserHLSConfigObserver : ObservableObject {
    @Published var config: UserHLSConfiguration = UserHLSConfiguration() {
        didSet {
            UserHLSConfiguration.save(config: config)
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
extension UserHLSConfiguration {
    private static func fileURL_() throws -> URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.dev.jdkula.HLSStreamer.config"
        )?.appendingPathComponent("HLSStreamer.config")
    }
    
    static func loadSync() throws -> UserHLSConfiguration {
        guard let fileURL = try fileURL_() else {
            return UserHLSConfiguration()
        }
        guard let file = try? FileHandle(forReadingFrom: fileURL) else {
            return UserHLSConfiguration()
        }
        let info = try JSONDecoder().decode(UserHLSConfiguration.self, from: file.availableData)
        return info
    }
    
    static func load(onComplete: @escaping ((Result<UserHLSConfiguration, Error>) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            do {
                guard let fileURL = try fileURL_() else {
                    DispatchQueue.main.async {
                        onComplete(.success(UserHLSConfiguration()))
                    }
                    return
                }
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        onComplete(.success(UserHLSConfiguration()))
                    }
                    return
                }
                let info = try JSONDecoder().decode(UserHLSConfiguration.self, from: file.availableData)
                DispatchQueue.main.async {
                    onComplete(.success(info))
                }
            } catch {
                onComplete(.failure(error))
            }
        }
    }
    
    static func save(config: UserHLSConfiguration) {
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
