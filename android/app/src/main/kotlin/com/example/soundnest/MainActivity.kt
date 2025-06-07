package com.example.soundnest

import android.media.*
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import com.google.android.gms.cast.MediaMetadata
import com.google.android.gms.cast.MediaInfo
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManagerListener
import com.google.android.gms.cast.framework.media.RemoteMediaClient
import com.google.android.gms.cast.MediaLoadRequestData

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.soundnest/audio"

    private var audioRecord: AudioRecord? = null
    private var audioTrack: AudioTrack? = null
    private var isLooping = false

    private var castContext: CastContext? = null
    private var castSession: CastSession? = null
    private var remoteMediaClient: RemoteMediaClient? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        try {
            castContext = CastContext.getSharedInstance(this)
            castContext?.sessionManager?.addSessionManagerListener(sessionManagerListener, CastSession::class.java)
            castSession = castContext?.sessionManager?.currentCastSession
            remoteMediaClient = castSession?.remoteMediaClient
        } catch (e: Exception) {
            Log.e("Cast", "CastContext initialization failed: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        castContext?.sessionManager?.removeSessionManagerListener(sessionManagerListener, CastSession::class.java)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMicLoop" -> {
                    startMicLoop()
                    result.success(null)
                }
                "stopMicLoop" -> {
                    stopMicLoop()
                    result.success(null)
                }
                "castPlay" -> {
                    val url = call.argument<String>("url")
                    val title = call.argument<String>("title") ?: "Audio"
                    if (url != null) {
                        castPlay(url, title)
                        result.success(null)
                    } else {
                        result.error("NO_URL", "URL is required", null)
                    }
                }
                "castPause" -> {
                    castPause()
                    result.success(null)
                }
                "castResume" -> {
                    castResume()
                    result.success(null)
                }
                "castStop" -> {
                    castStop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startMicLoop() {
        if (isLooping) return

        val sampleRate = 44100
        val bufferSize = AudioRecord.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize
        )

        audioTrack = AudioTrack(
            AudioManager.STREAM_MUSIC,
            sampleRate,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize,
            AudioTrack.MODE_STREAM
        )

        audioRecord?.startRecording()
        audioTrack?.play()
        isLooping = true

        Log.d("MicLoop", "🟢 Mic loop started")

        thread {
            val buffer = ByteArray(bufferSize)
            while (isLooping && audioRecord?.recordingState == AudioRecord.RECORDSTATE_RECORDING) {
                val read = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                if (read > 0) {
                    audioTrack?.write(buffer, 0, read)
                }
            }
            Log.d("MicLoop", "🔴 Mic loop stopped")
        }
    }

    private fun stopMicLoop() {
        isLooping = false
        audioRecord?.stop()
        audioTrack?.stop()
        audioRecord?.release()
        audioTrack?.release()
        audioRecord = null
        audioTrack = null
    }

    private fun castPlay(url: String, title: String) {
        if (castSession == null || !castSession!!.isConnected) {
            Log.e("Cast", "No Cast session available")
            return
        }

        val metadata = MediaMetadata(MediaMetadata.MEDIA_TYPE_MUSIC_TRACK)
        metadata.putString(MediaMetadata.KEY_TITLE, title)

        val mediaInfo = MediaInfo.Builder(url)
            .setContentType("audio/mpeg")
            .setStreamType(MediaInfo.STREAM_TYPE_BUFFERED)
            .setMetadata(metadata)
            .build()

        val requestData = MediaLoadRequestData.Builder()
            .setMediaInfo(mediaInfo)
            .build()

        remoteMediaClient?.load(requestData)
        Log.d("Cast", "Cast play requested: $url")
    }

    private fun castPause() {
        remoteMediaClient?.pause()
        Log.d("Cast", "Cast pause requested")
    }

    private fun castResume() {
        remoteMediaClient?.play()
        Log.d("Cast", "Cast resume requested")
    }

    private fun castStop() {
        remoteMediaClient?.stop()
        Log.d("Cast", "Cast stop requested")
    }

    private val sessionManagerListener = object : SessionManagerListener<CastSession> {
        override fun onSessionStarted(session: CastSession, sessionId: String) {
            Log.d("Cast", "Session started: $sessionId")
            castSession = session
            remoteMediaClient = session.remoteMediaClient
        }

        override fun onSessionStartFailed(session: CastSession, error: Int) {
            Log.e("Cast", "Session start failed with error code: $error")
        }

        override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
            Log.d("Cast", "Session resumed")
            castSession = session
            remoteMediaClient = session.remoteMediaClient
        }

        override fun onSessionResumeFailed(session: CastSession, error: Int) {
            Log.e("Cast", "Session resume failed with error code: $error")
        }

        override fun onSessionEnded(session: CastSession, error: Int) {
            Log.d("Cast", "Session ended")
            castSession = null
            remoteMediaClient = null
        }

        override fun onSessionStarting(session: CastSession) {}
        override fun onSessionEnding(session: CastSession) {}
        override fun onSessionSuspended(session: CastSession, reason: Int) {}
        override fun onSessionResuming(session: CastSession, sessionId: String) {}
    }
}
