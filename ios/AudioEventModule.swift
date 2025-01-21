//
//  AudioEventModule.swift
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

import React
import os

@objc(AudioEventModule)
class AudioEventModule: RCTEventEmitter {
    static var shared:AudioEventModule?
  
    override init() {
      super.init()
      AudioEventModule.shared = self
    }
  
    // MARK: - RCTEventEmitter Overrides
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    override func supportedEvents() -> [String] {
        return ["onAudioStateChange", "onAudioProgress"]
    }

    // MARK: - Event Dispatch Methods
    func emitStateChange(state: String, message: String? = nil) {
        var event: [String: Any] = ["state": state]
        if let message = message {
            event["message"] = message
        }
        os_log("Sending state change event")
        sendEvent(withName: "onAudioStateChange", body: event)
    }

    func emitProgressUpdate(progress: Double, currentTime: Double, totalDuration: Double) {
        let event: [String: Any] = [
            "progress": progress,
            "currentTime": currentTime,
            "totalDuration": totalDuration,
        ]
        os_log("Sending progress event")
        sendEvent(withName: "onAudioProgress", body: event)
    }
}
