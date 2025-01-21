import AVFoundation
import Foundation
import React
import MediaPlayer

// Media Player Info structure
struct MediaPlayerInfo {
    var title: String?
    var artist: String?
    var album: String?
    var duration: Double?
}

@objc(MediaPlayerModule)
class MediaPlayerModule: NSObject {
  
    private var audioURL: URL? = nil
    // Use AudioModule to handle audio functions
    private let audioModule = AudioModule()
  
    // Media Player Info
    static var mediaPlayerInfo: MediaPlayerInfo?
  
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
  
    // Set Media Player Info
    @objc func setMediaPlayerInfo(_ url: URL, title: String, artist: String, album: String, duration: Double) {
        self.audioURL = url
        MediaPlayerModule.mediaPlayerInfo = MediaPlayerInfo(
            title: title, artist: artist, album: album, duration: duration
        )
        // Update Now Playing Info (for remote controls, lock screen, etc.)
        updateMediaPlayerInfo()
    }
  
    // Play audio using AudioModule
    @objc func playAudio() {
      guard self.audioURL != nil else {
            print("Error: Audio URL is not set.")
            return
        }
      
      // Play the audio with AudioModule
      audioModule.downloadAndPlayAudio(self.audioURL!, resolver: { _ in
          print("Audio is playing successfully")
          
          // Update Now Playing Info
          self.updateMediaPlayerInfo()
          
          // Setup remote media controls (e.g., lock screen, control center)
          self.setupMediaPlayerNotificationView()
      }, rejecter: { errorCode, errorMessage, error in
          print("Error: \(errorMessage ?? "")")
      })
    }
  
    // Pause the audio
    @objc func pauseAudio() {
        audioModule.pauseAudio()
    }
  
    // Stop the audio
    @objc func stopAudio() {
        audioModule.stopAudio()
    }
  
  // Update Now Playing Info (for lock screen, control center)
    private func updateMediaPlayerInfo() {
        guard let info = MediaPlayerModule.mediaPlayerInfo else {
            return
        }
        
        let nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: info.title ?? "",
            MPMediaItemPropertyArtist: info.artist ?? "",
            MPMediaItemPropertyAlbumTitle: info.album ?? "",
            MPMediaItemPropertyPlaybackDuration: info.duration ?? 0.0,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: 0.0
        ]
        
        // If you have artwork, you can add it here
        // if let artwork = MPMediaItemArtwork(/* your artwork here */) {
        //     nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        // }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // Setup remote media controls (for play, pause, skip)
    private func setupMediaPlayerNotificationView() {
        let commandCenter = MPRemoteCommandCenter.shared()
      
        // Play/Pause toggle button
        commandCenter.playCommand.addTarget(self, action: #selector(playAudio))
        commandCenter.pauseCommand.addTarget(self, action: #selector(pauseAudio))
        commandCenter.stopCommand.addTarget(self, action: #selector(stopAudio))
    }
  
  
    // Required for RCT_EXTERN_MODULE
    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
}
