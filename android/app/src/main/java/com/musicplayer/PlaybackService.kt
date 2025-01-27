package com.musicplayer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.OptIn
import androidx.core.app.NotificationCompat
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.SessionCommand
import androidx.media3.session.CommandButton
import androidx.media3.common.util.UnstableApi
import androidx.media3.session.SessionResult
import com.google.common.util.concurrent.ListenableFuture
import com.google.common.util.concurrent.Futures
import com.musicplayer.ExoPlayerSingleton

class PlaybackService : MediaSessionService() {
    private var mediaSession: MediaSession? = null
    private lateinit var exoPlayer: ExoPlayer
    private val customCommandPlayPause = SessionCommand("PLAY_PAUSE", Bundle.EMPTY)
    private val customCommandNext = SessionCommand("NEXT", Bundle.EMPTY)
    private val customCommandPrevious = SessionCommand("PREVIOUS", Bundle.EMPTY)
    private val customCommandSeek = SessionCommand("SEEK", Bundle.EMPTY)
    private val notificationChannelId = "playback_channel"
    private val notificationId = 1
    private val handler = Handler(Looper.getMainLooper())

    private val playPauseButton = CommandButton.Builder()
        .setDisplayName("Play/Pause")
        .setSessionCommand(customCommandPlayPause)
        .build()

    private val nextButton = CommandButton.Builder()
        .setDisplayName("Next")
        .setSessionCommand(customCommandNext)
        .build()

    private val previousButton = CommandButton.Builder()
        .setDisplayName("Previous")
        .setSessionCommand(customCommandPrevious)
        .build()

    @OptIn(UnstableApi::class) override fun onCreate() {
        super.onCreate()
        exoPlayer = ExoPlayerSingleton.getInstance(applicationContext)
        Log.d("PlaybackService", exoPlayer.toString())
        val player = exoPlayer
        createNotificationChannel()
        // Build the session with the custom layout and control buttons
        mediaSession = MediaSession.Builder(this, player)
            .setCallback(MyCallback())
            .setMediaButtonPreferences(listOf(playPauseButton, nextButton, previousButton))
            .build()
        Log.d("PlaybackService", mediaSession.toString())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        intent?.toString()?.let { Log.d("PlaybackService", it) }
        when (intent?.action) {
            "SHOW_NOTIFICATION" -> {
                val title = intent.getStringExtra("TITLE")
                val artist = intent.getStringExtra("ARTIST")
                val album = intent.getStringExtra("ALBUM")
                val duration = intent.getLongExtra("DURATION", 0)
                startForeground(notificationId, createMediaStyleNotification(title, artist, album, duration))
                handler.post(updateNotificationRunnable)
            }
        }
        return START_STICKY
    }

    private inner class MyCallback : MediaSession.Callback {
        @OptIn(UnstableApi::class) override fun onConnect(
            session: MediaSession,
            controller: MediaSession.ControllerInfo
        ): MediaSession.ConnectionResult {
            Log.d("PlaybackService", session.toString())
            return MediaSession.ConnectionResult.AcceptedResultBuilder(session)
                .setAvailablePlayerCommands(
                    MediaSession.ConnectionResult.DEFAULT_PLAYER_COMMANDS.buildUpon()
                        .remove(Player.COMMAND_SEEK_TO_NEXT)
                        .remove(Player.COMMAND_SEEK_TO_PREVIOUS)
                        .build()
                )
                .setAvailableSessionCommands(
                    MediaSession.ConnectionResult.DEFAULT_SESSION_COMMANDS.buildUpon()
                        .add(customCommandPlayPause)
                        .add(customCommandNext)
                        .add(customCommandPrevious)
                        .add(customCommandSeek)
                        .build()
                )
                .build()
    }

        override fun onCustomCommand(
            session: MediaSession,
            controller: MediaSession.ControllerInfo,
            customCommand: SessionCommand,
            args: Bundle
        ): ListenableFuture<SessionResult> {
            return when (customCommand.customAction) {
                "PLAY_PAUSE" -> {
                    if (exoPlayer.isPlaying == true) {
                        exoPlayer.pause()
    
                    } else {
                        exoPlayer.play()
                    }
                    Futures.immediateFuture(SessionResult(SessionResult.RESULT_SUCCESS))
                }
                "NEXT" -> {
                    exoPlayer.seekToNextMediaItem()
                    Futures.immediateFuture(SessionResult(SessionResult.RESULT_SUCCESS))
                }
                "PREVIOUS" -> {
                    exoPlayer.seekToPreviousMediaItem()
                    Futures.immediateFuture(SessionResult(SessionResult.RESULT_SUCCESS))
                }
                "SEEK" -> {
                    val seekPosition = args.getLong("SEEK_POSITION", 0)
                    exoPlayer.seekTo(seekPosition)
                    Futures.immediateFuture(SessionResult(SessionResult.RESULT_SUCCESS))
                }
                else -> super.onCustomCommand(session, controller, customCommand, args)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        ExoPlayerSingleton.releaseInstance() // Release ExoPlayer when the service is destroyed
        mediaSession?.release() // Release MediaSession
        handler.removeCallbacks(updateNotificationRunnable)
    }

    override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaSession? {
        return mediaSession
    }

    @OptIn(UnstableApi::class) private fun createMediaStyleNotification(title: String?, artist: String?, album: String?, duration: Long): Notification {
        val playPauseIntent = createPendingIntent("PLAY_PAUSE")
        val nextIntent = createPendingIntent("NEXT")
        val previousIntent = createPendingIntent("PREVIOUS")

        val currentPosition = exoPlayer.currentPosition
        val progress = if (duration > 0) (currentPosition * 100 / duration).toInt() else 0

        return NotificationCompat.Builder(this, notificationChannelId)
            .setContentTitle(title)
            .setContentText(artist)
            .setSubText(album)
            .setSmallIcon(R.drawable.ic_music_note)
            .setProgress(100, progress, false)
            .addAction(
                R.drawable.ic_stop,
                "Previous",
                previousIntent
            )
            .addAction(
                if (exoPlayer.isPlaying == true) R.drawable.ic_pause else R.drawable.ic_play,
                if (exoPlayer.isPlaying == true) "Pause" else "Play",
                playPauseIntent
            )
            .addAction(
                R.drawable.ic_stop,
                "Next",
                nextIntent
            )
            .setStyle(
                androidx.media.app.NotificationCompat.MediaStyle()
                    .setMediaSession(mediaSession?.sessionCompatToken)
                    .setShowActionsInCompactView(0, 1, 2) // Compact view with all controls
            )
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true) // Sticky notification
            .build()
    }

    private fun updateNotification(title: String?, artist: String?, album: String?, duration: Long) {
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId, createMediaStyleNotification(title, artist, album, duration))
    }

    private fun createNotificationChannel() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                notificationChannelId,
                "Playback Notifications",
                NotificationManager.IMPORTANCE_LOW
            )
            channel.description = "Notifications for playback controls"
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createPendingIntent(action: String): PendingIntent {
        val intent = Intent(this, PlaybackService::class.java).apply {
            this.action = action
        }
        return PendingIntent.getService(
            this,
            action.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private val updateNotificationRunnable = object : Runnable {
        override fun run() {
            val title = exoPlayer.mediaMetadata.title?.toString()
            val artist = exoPlayer.mediaMetadata.artist?.toString()
            val album = exoPlayer.mediaMetadata.albumTitle?.toString()
            val duration = exoPlayer.duration
            updateNotification(title, artist, album, duration)
            handler.postDelayed(this, 1000) // Update every second
        }
    }
}
