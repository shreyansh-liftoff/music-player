//
//  AudioModule.swift
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

import AVFoundation
import Foundation
import React
import MediaPlayer
import UIKit

@objc(AudioModule)
class AudioModule: NSObject, AVAudioPlayerDelegate {
    private let fileModule = FileModule.shared
    var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    private var progressTimer: Timer?
    private var currentPlaybackPosition: TimeInterval = 0.0
    private var audioURL: URL?
  
    private func setUpSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print(error)
        }
    }

    init(audioPlayer: AVAudioPlayer? = nil, isPlaying: Bool = false, progressTimer: Timer? = nil) {
        super.init()
        self.audioPlayer = audioPlayer
        self.isPlaying = isPlaying
        self.progressTimer = progressTimer
    }
    // Default initializer
    override init() {
        super.init()
        self.setUpSession()
    }

    // MARK: - Public Methods
  
    // Set Media Player Info
    @objc func setMediaPlayerInfo(_ title: String, artist: String, album: String, duration: String) {
      let nowPlayingInfo: [String: Any] = [
          MPMediaItemPropertyTitle: title,
          MPMediaItemPropertyArtist: artist,
          MPMediaItemPropertyAlbumTitle: album,
          MPMediaItemPropertyPlaybackDuration: duration,
          MPNowPlayingInfoPropertyPlaybackRate: 1.0,
          MPNowPlayingInfoPropertyElapsedPlaybackTime: 0.0
      ]
      
      // If you have artwork, you can add it here
      // if let artwork = MPMediaItemArtwork(/* your artwork here */) {
      //     nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
      // }
      
      // Log the nowPlayingInfo dictionary
      os_log("Now Playing Info: %{public}@", log: OSLog.default, type: .info, nowPlayingInfo.description)
      
      MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    @objc func downloadAndPlayAudio(
        _ remoteURL: URL, resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) {
        // Download or retrieve from cache
        fileModule.downloadFile(from: remoteURL) { [weak self] result in
            switch result {
            case .success(let localURL):
                // Play audio from local URL
                self?.audioURL = localURL
                self?.playAudio(from: localURL)
                resolver(localURL.absoluteString)
            case .failure(let error):
                rejecter("DOWNLOAD_ERROR", "Failed to download audio", error)
            }
        }
    }

  @objc func playAudio(from url: URL) {
        do {
            if let player = audioPlayer {
                player.pause()  // Pause existing player if any
            }
            print(url)
            // Initialize AVAudioPlayer
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.currentTime = self.currentPlaybackPosition
            audioPlayer?.play()
            isPlaying = true
            // Emit state change event
            AudioEventModule.shared?.emitStateChange(state: "playing")
            // Start sending progress updates
            startProgressUpdates()
            // Setup remote media controls
            setupMediaPlayerNotificationView()
        } catch {
            os_log(
                "Error initializing audio player: %{public}@", log: OSLog.default, type: .error,
                error.localizedDescription)
                AudioEventModule.shared?.emitStateChange(state: "error", message: error.localizedDescription)
        }
    }

    @objc func pauseAudio() {
        currentPlaybackPosition = audioPlayer?.currentTime ?? 0.0
        audioPlayer?.pause()
        isPlaying = false

        // Emit state change event
        AudioEventModule.shared?.emitStateChange(state: "paused")
        // Stop sending progress updates
        stopProgressUpdates()
    }

    @objc func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentPlaybackPosition = 0.0

        // Emit state change event
        AudioEventModule.shared?.emitStateChange(state: "stopped")
        // Stop sending progress updates
        stopProgressUpdates()
    }

    @objc func seek(_ timeInSeconds: Double) {
        guard let player = audioPlayer else { return }

        // Ensure the seek time is within the duration bounds
        self.currentPlaybackPosition = timeInSeconds
        player.currentTime = timeInSeconds
        // Emit the current time and progress update after seeking
        sendProgressUpdate()

        // Emit state change event
        AudioEventModule.shared?.emitStateChange(state: "seeking", message: "Seeked to \(timeInSeconds) seconds")
    }

    // MARK: - Get Total Duration Method

    @objc func getTotalDuration(
        _ remoteURL: URL, resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) {
        // Download or retrieve from cache
        fileModule.downloadFile(from: remoteURL) { [weak self] result in
            switch result {
            case .success(let localURL):
                // Initialize audio player with the downloaded file
                do {
                    self?.audioPlayer = try AVAudioPlayer(contentsOf: localURL)
                    self?.audioPlayer?.prepareToPlay()

                    let duration = self?.audioPlayer?.duration
                    if (duration ?? 0) != 0 {
                        resolver(duration)
                    } else {
                        rejecter("ERROR", "Failed to retrieve total duration", nil)
                    }
                } catch {
                    rejecter("ERROR", "Failed to initialize audio player", error)
                }

            case .failure(let error):
                rejecter("DOWNLOAD_ERROR", "Failed to download audio", error)
            }
        }
    }

    // MARK: - AVAudioPlayerDelegate Methods

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            AudioEventModule.shared?.emitStateChange(state: "completed")
            stopProgressUpdates()
        } else {
            AudioEventModule.shared?.emitStateChange(state: "error", message: "Playback failed")
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            os_log(
                "Audio decode error: %{public}@", log: OSLog.default, type: .error,
                error.localizedDescription)
                AudioEventModule.shared?.emitStateChange(state: "error", message: error.localizedDescription)
        }
    }
  
  // Setup remote media controls (for play, pause, skip)
  private func setupMediaPlayerNotificationView() {
      let commandCenter = MPRemoteCommandCenter.shared()
    
      // Play command
      commandCenter.playCommand.isEnabled = true
      commandCenter.playCommand.addTarget { [weak self] event in
          self?.playAudio(from: self!.audioURL!)
          return .success
      }
    
      // Pause command
      commandCenter.pauseCommand.isEnabled = true
      commandCenter.pauseCommand.addTarget { [weak self] event in
          self?.pauseAudio()
          return .success
      }
    
      // Stop command
      commandCenter.stopCommand.isEnabled = true
      commandCenter.stopCommand.addTarget { [weak self] event in
          self?.stopAudio()
          return .success
      }
  }

    // MARK: - Observing Audio Progress

  
  private func startProgressUpdates() {
          stopProgressUpdates()  // Clean up any existing timer
          
          os_log("Attempting to start progress update timer...", log: OSLog.default, type: .info)
          
          // Create the timer on the main thread
          DispatchQueue.main.async { [weak self] in
              guard let self = self else {
                  os_log("Self is nil when trying to create timer", log: OSLog.default, type: .error)
                  return
              }
              
              self.progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                  guard let self = self else {
                      os_log("Self deallocated, invalidating timer", log: OSLog.default, type: .info)
                      timer.invalidate()
                      return
                  }
                  
                  guard let player = self.audioPlayer, player.isPlaying else {
                      os_log("Audio player is not playing, skipping progress update", log: OSLog.default, type: .info)
                      self.stopProgressUpdates()
                      return
                  }
                  
                  os_log("Timer fired - Current time: %.2f", log: OSLog.default, type: .info, player.currentTime)
                  self.sendProgressUpdate()
              }
              
              if let timer = self.progressTimer {
                  RunLoop.main.add(timer, forMode: .common)
                  os_log("Successfully created and scheduled timer", log: OSLog.default, type: .info)
              } else {
                  os_log("Failed to create timer", log: OSLog.default, type: .error)
              }
          }
      }

  private func stopProgressUpdates() {
      if let timer = progressTimer {
          timer.invalidate()
          os_log("Timer invalidated", log: OSLog.default, type: .info)
      }
      progressTimer = nil
  }

    private func sendProgressUpdate() {
        guard let player = audioPlayer else { return }

        let progress = player.currentTime / player.duration
        let currentTime = player.currentTime
        let totalDuration = player.duration
      AudioEventModule.shared?.emitProgressUpdate(
            progress: progress, currentTime: currentTime, totalDuration: totalDuration)
    }

    // MARK: - Cleanup

    deinit {
        audioPlayer = nil
    }
}
