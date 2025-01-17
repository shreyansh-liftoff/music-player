package com.audioplayer

import android.media.MediaPlayer
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class AudioPlayerModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    private var mediaPlayer: MediaPlayer? = null

    override fun getName(): String {
        return "AudioPlayer"
    }

    @ReactMethod
    fun play(filePath: String) {
        if (mediaPlayer == null) {
            val resId = reactApplicationContext.resources.getIdentifier(filePath, "raw", reactApplicationContext.packageName)
            mediaPlayer = MediaPlayer.create(reactApplicationContext, resId)
        }
        mediaPlayer?.start()
    }

    @ReactMethod
    fun pause() {
        mediaPlayer?.pause()
    }

    @ReactMethod
    fun stop() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
    }
}
