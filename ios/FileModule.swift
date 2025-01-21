//
//  FileModule.swift
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

import Foundation
import os

class FileModule {
    static let shared = FileModule()
    
    private let fileManager = FileManager.default
    
    private init() {}
  
    
    /// Download a file or return a cached/local file path
    func downloadFile(from remoteURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let key = remoteURL.absoluteString
        
        // Check cache
        if let cachedURL = CacheModule.shared.getCachedFile(for: key) {
            completion(.success(cachedURL))
            return
        }
        
        // Define destination path
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(remoteURL.lastPathComponent)
        
        // Check if file exists locally
        if fileManager.fileExists(atPath: destinationURL.path) {
            os_log("File already exists locally: %{public}@", log: OSLog.default, type: .info, destinationURL.absoluteString)
            CacheModule.shared.cacheFile(destinationURL, for: key)
            completion(.success(destinationURL))
            return
        }
        
        // Download the file
        let task = URLSession.shared.downloadTask(with: remoteURL) { localURL, response, error in
            if let error = error {
                os_log("Download error: %{public}@", log: OSLog.default, type: .error, error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            guard let localURL = localURL else {
                let error = NSError(domain: "FileModule", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to download file."])
                os_log("Local URL is nil after download.", log: OSLog.default, type: .error)
                completion(.failure(error))
                return
            }
            
            do {
                // Move the file to the destination
                try self.fileManager.moveItem(at: localURL, to: destinationURL)
                os_log("File downloaded to: %{public}@", log: OSLog.default, type: .info, destinationURL.absoluteString)
                
                // Cache the file
                CacheModule.shared.cacheFile(destinationURL, for: key)
                completion(.success(destinationURL))
            } catch {
                os_log("Error moving downloaded file: %{public}@", log: OSLog.default, type: .error, error.localizedDescription)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
