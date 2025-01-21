//
//  CacheModule.swift
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

import Foundation
import os

class CacheModule {
    static let shared = CacheModule()
    
    private let cache = NSCache<NSString, NSURL>()
    
    private init() {}
    
    /// Retrieve a cached file URL if it exists
    func getCachedFile(for key: String) -> URL? {
        if let cachedURL = cache.object(forKey: key as NSString) {
            os_log("Cache hit for key: %{public}@", log: OSLog.default, type: .info, key)
            return cachedURL as URL
        }
        os_log("Cache miss for key: %{public}@", log: OSLog.default, type: .info, key)
        return nil
    }
    
    /// Save a file URL to the cache
    func cacheFile(_ url: URL, for key: String) {
        cache.setObject(url as NSURL, forKey: key as NSString)
        os_log("Cached file for key: %{public}@", log: OSLog.default, type: .info, key)
    }
}
