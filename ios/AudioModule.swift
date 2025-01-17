import AVFoundation
import Foundation
import MediaPlayer
import React
import os

@objc(AudioModule)
class AudioModule: RCTEventEmitter {
  private var audioPlayer: AVAudioPlayer?
  private var previousPlayURL: URL?
  private var previousURL: URL?
  private var lastPlayingTime: TimeInterval = 0
  private var timer: Timer?
  private var progressUpdateListeners: Bool = false
  private var nowPlayingInfo: [String: Any] = [:]

  override static func requiresMainQueueSetup() -> Bool {
    return false
  }

  override func supportedEvents() -> [String] {
    return ["onProgressUpdate"]
  }
  // Override to handle when a listener is added or removed
  override func startObserving() {
    super.startObserving()
    // Indicate that listeners are now present
    progressUpdateListeners = true
  }

  override func stopObserving() {
    super.stopObserving()
    // Indicate that listeners have been removed
    progressUpdateListeners = false
  }
  
  private func setupRemoteCommandCenter() {
    let commandCenter = MPRemoteCommandCenter.shared()

    commandCenter.playCommand.addTarget { [weak self] event in
        self?.audioPlayer?.play()
        return .success
    }

    commandCenter.pauseCommand.addTarget { [weak self] event in
        self?.audioPlayer?.pause()
        return .success
    }

    commandCenter.stopCommand.addTarget { [weak self] event in
        self?.audioPlayer?.stop()
        return .success
    }

    commandCenter.nextTrackCommand.addTarget { event in
        // Handle next track
        return .success
    }

    commandCenter.previousTrackCommand.addTarget { event in
        // Handle previous track
        return .success
    }
  }
  
  private func setupAudioSession() {
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try AVAudioSession.sharedInstance().setActive(true)
        os_log("Audio session activated successfully.", log: OSLog.default, type: .info)
    } catch {
        os_log("Failed to activate audio session: %@", log: OSLog.default, type: .error, error.localizedDescription)
    }
  }
  
  private func configureNowPlayingInfo(
      title: String, artist: String, duration: Double, artworkImage: URL?
  ) {
      // Set up basic metadata
      nowPlayingInfo[MPMediaItemPropertyTitle] = title
      nowPlayingInfo[MPMediaItemPropertyArtist] = artist
      nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
      nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

      // If artwork URL is provided, download and set it
      if let artworkURL = artworkImage {
          downloadImage(from: artworkURL) { image in
              if let image = image {
                  let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                      return image
                  }
                  // Set artwork only after the image has been downloaded
                  self.nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
              }
              // Update NowPlayingInfo after artwork is set or if no artwork exists
            print(self.nowPlayingInfo)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
          }
      } else {
          // If no artwork URL is provided, update without artwork
          MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
      }
  }

  // Download image from URL
  private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
      let session = URLSession.shared
      let task = session.dataTask(with: url) { (data, response, error) in
          guard let data = data, error == nil else {
              completion(nil)
              return
          }
          if let image = UIImage(data: data) {
              completion(image)
          } else {
              completion(nil)
          }
      }
      task.resume()
  }

  @objc func setMediaPlayerInfo(_ title: String, artist: String, imageURL: String?) {
      DispatchQueue.main.async {
          // Ensure audioPlayer is available
        print(title, artist, imageURL ?? "")
          guard let playerDuration = self.audioPlayer?.duration else { return }
        self.configureNowPlayingInfo(title: title, artist: artist, duration: playerDuration, artworkImage: self.getURL(from: imageURL ?? ""))
      }
  }

  @objc func getTotalDuration(_ filePath: String, callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async {
      // Ensure we have a valid URL
      guard let url = self.getURL(from: filePath) else {
        os_log("Invalid file path: %{public}@", log: OSLog.default, type: .error, filePath)
        callback([""])
        return
      }

      self.checkIfSameURLIsPlayed(url: url) { [weak self] localURL in
        guard let localURL = localURL else {
          os_log("Error: Failed to get local URL for playback.", log: OSLog.default, type: .error)
          callback([""])
          return
        }
        do {
          // Use the URL to initialize the AVAudioPlayer
          self?.audioPlayer = try AVAudioPlayer(contentsOf: localURL)
          self?.audioPlayer?.prepareToPlay()

          // Get the total duration of the audio file
          let duration = self?.audioPlayer?.duration ?? 0
          os_log(
            "Total duration of audio file: %{public}f", log: OSLog.default, type: .info, duration)

          // Return the duration back to React Native
          callback([duration])
        } catch {
          os_log(
            "Error initializing AVAudioPlayer: %{public}@", log: OSLog.default, type: .error,
            error.localizedDescription)
          callback([""])
        }
      }
    }
  }

  @objc func downloadFileFromURL(url: URL, completion: @escaping (URL?) -> Void) {
    let downloadTask = URLSession.shared.downloadTask(with: url) { (url, response, error) in
      if let error = error {
        os_log(
          "Error downloading audio: %{public}@", log: OSLog.default, type: .error,
          error.localizedDescription)
        completion(nil)
        return
      }

      guard let localURL = url else {
        os_log("Failed to download file.", log: OSLog.default, type: .error)
        completion(nil)
        return
      }

      os_log(
        "Downloaded file at %{public}@", log: OSLog.default, type: .info, localURL.absoluteString)
      completion(localURL)
    }
    downloadTask.resume()
  }

  @objc func checkIfSameURLIsPlayed(url: URL, completion: @escaping (URL?) -> Void) {
    if url == self.previousURL {
      os_log("Playing the same URL again.", log: OSLog.default, type: .info)
      completion(self.previousPlayURL)
    } else {
      self.downloadFileFromURL(url: url) { [weak self] newLocalURL in
        if let newLocalURL = newLocalURL {
          self?.previousPlayURL = newLocalURL
          self?.previousURL = url
          completion(newLocalURL)
        } else {
          os_log("Failed to download new file.", log: OSLog.default, type: .error)
          completion(nil)
        }
      }
    }
  }

  @objc func play(
    _ filePath: String,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async {
      self.setupAudioSession()
      guard let url = self.getURL(from: filePath) else {
        os_log("Invalid URL for audio file: %{public}@", log: OSLog.default, type: .error, filePath)

        rejecter("INVALID_URL", "The URL provided is invalid.", nil)
        return
      }

      self.checkIfSameURLIsPlayed(url: url) { [weak self] localURL in
        guard let localURL = localURL else {
          os_log("Error: Failed to get local URL for playback.", log: OSLog.default, type: .error)
          rejecter("DOWNLOAD_ERROR", "Failed to download the audio file.", nil)
          return
        }

        do {
          self?.audioPlayer = try AVAudioPlayer(contentsOf: localURL)
          self?.audioPlayer?.prepareToPlay()
          self?.audioPlayer?.currentTime = self!.lastPlayingTime
          self?.audioPlayer?.play()
          os_log("Audio is now playing from downloaded file.", log: OSLog.default, type: .info)
          self?.startTracking()
          resolver("Playing audio successfully.")
        } catch {
          os_log(
            "Error initializing AVAudioPlayer: %{public}@", log: OSLog.default, type: .error,
            error.localizedDescription)
          rejecter("PLAYBACK_ERROR", "Error initializing the audio player.", error)
        }
      }
    }
  }

  @objc func pause() {
    DispatchQueue.main.async {
      self.lastPlayingTime = self.audioPlayer!.currentTime
      self.audioPlayer?.pause()
      self.stopTracking()
    }
  }

  @objc func stop() {
    DispatchQueue.main.async {
      self.audioPlayer?.stop()
      self.audioPlayer = nil
      self.lastPlayingTime = 0
      self.previousURL = nil
      self.previousPlayURL = nil
      self.stopTracking()
    }
  }

  @objc func seek(
    _ interval: Double, resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let audioPlayer = self.audioPlayer else {
      reject("SEEK_ERROR", "Audio player is not initialized", nil)
      return
    }

    // Get the current position
    var newPosition = audioPlayer.currentTime + interval

    // Ensure that the new position is within the bounds of the audio
    newPosition = max(0, min(newPosition, audioPlayer.duration))

    // Seek to the new position
    audioPlayer.currentTime = newPosition
    self.updateProgress()
    resolve(newPosition)
  }

  @objc func startTracking() {
    // Start a timer to send progress updates every second
    os_log("Starting tracking", log: OSLog.default, type: .info)
    timer = Timer.scheduledTimer(
      timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil,
      repeats: true)
  }

  @objc func stopTracking() {
    timer?.invalidate()
    timer = nil
  }

  @objc func updateProgress() {
    os_log("Sending update")
    guard let player = audioPlayer else { return }
    let progress = player.currentTime / player.duration * 100  // Progress as percentage
    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
    nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.isPlaying ? 1.0 : 0.0
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

    if progress >= 99.5 {
      print("Progress is at or near 100%. Stopping progress updates.")
      stopTracking()
      sendProgressUpdate(progress: 100, currentTime: player.currentTime)  // Ensure we send 100% as final progress
      return
    }

    // Only send the event if there are listeners registered
    os_log("Has event listeners ->", log: OSLog.default, type: .info, self.progressUpdateListeners)
    if self.progressUpdateListeners {
      sendProgressUpdate(progress: progress, currentTime: player.currentTime)
    }
  }

  func sendProgressUpdate(progress: Double, currentTime: Double) {
    // Emit the "onProgressUpdate" event to JavaScript
    self.sendEvent(
      withName: "onProgressUpdate", body: ["progress": progress, "currentTime": currentTime])
  }

  deinit {
    stopTracking()
  }

  private func getURL(from filePath: String) -> URL? {
    if filePath.starts(with: "http") {
      return URL(string: filePath)
    } else {
      return URL(fileURLWithPath: filePath)
    }
  }
}
