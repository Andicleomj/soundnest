package com.example.soundnest

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.media.AudioManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import android.util.Log


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.soundnest/audio"

    private var audioRecord: AudioRecord? = null
    private var audioTrack: AudioTrack? = null
    private var isLooping = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startMicLoop" -> {
                        startMicLoop()
                        result.success(null)
                    }
                    "stopMicLoop" -> {
                        stopMicLoop()
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

    Log.d("MicLoop", "🟢 Mic loop started — suara akan diputar di speaker")

    thread {
        val buffer = ByteArray(bufferSize)
        while (isLooping && audioRecord?.recordingState == AudioRecord.RECORDSTATE_RECORDING) {
            val read = audioRecord?.read(buffer, 0, buffer.size) ?: 0
            if (read > 0) {
                audioTrack?.write(buffer, 0, read)
                Log.d("MicLoop", "📢 Audio captured & played ($read bytes)")
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
}
