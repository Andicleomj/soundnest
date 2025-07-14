package com.example.soundnest

import android.Manifest
import android.content.pm.PackageManager
import android.media.*
import android.os.Bundle
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import kotlin.math.min

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.example.soundnest/audio"
        private const val REQ_RECORD_AUDIO = 1001
    }

    private var audioRecord: AudioRecord? = null
    private var audioTrack: AudioTrack? = null
    private var isLooping = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMicLoop" -> {
                    if (hasMicPerm()) {
                        startMicLoop()
                        result.success(null)
                    } else {
                        requestMicPerm()
                        result.error("PERMISSION", "RECORD_AUDIO not granted", null)
                    }
                }
                "stopMicLoop" -> {
                    stopMicLoop()
                    result.success(null)
                }
                "setVolumeBasedOnSPL" -> {
                    val v = call.argument<Double>("volume")?.toFloat() ?: 1f
                    setVolume(v)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /* ───────────────────────── Permission ───────────────────────── */

    private fun hasMicPerm() =
        ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED

    private fun requestMicPerm() =
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), REQ_RECORD_AUDIO)

    /* ─────────────────────────  Mic Loop  ───────────────────────── */

    private fun startMicLoop() {
        if (isLooping) return

        val sampleRate = 44_100
        val bufferSize = AudioRecord.getMinBufferSize(
            sampleRate, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT
        )

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC, sampleRate, AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT, bufferSize
        ).apply {
            try {
                startRecording()
            } catch (e: IllegalStateException) {
                Log.e("Audio", "startRecording failed ${e.message}")
                release(); return
            }
        }

        audioTrack = AudioTrack(
            AudioManager.STREAM_MUSIC, sampleRate, AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT, bufferSize, AudioTrack.MODE_STREAM
        ).apply {
            try {
                play()
            } catch (e: IllegalStateException) {
                Log.e("Audio", "play() failed ${e.message}")
                release(); return
            }
        }

        isLooping = true
        thread {
            val buf = ByteArray(bufferSize)
            while (isLooping && audioRecord?.recordingState == AudioRecord.RECORDSTATE_RECORDING) {
                val read = audioRecord?.read(buf, 0, buf.size) ?: 0
                if (read > 0) audioTrack?.write(buf, 0, read)
            }
        }
    }

    private fun stopMicLoop() {
        isLooping = false
        audioRecord?.run { stop(); release() }
        audioTrack?.run { stop(); release() }
        audioRecord = null
        audioTrack = null
    }

    /* ─────────────────────────  Volume  ───────────────────────── */

    private fun setVolume(v: Float) {
        val adj = min(v, 1f).coerceAtLeast(0.1f)
        audioTrack?.setVolume(adj)
    }

    /* ───────────────────────── Lifecycle ───────────────────────── */

    override fun onDestroy() {
        stopMicLoop()
        super.onDestroy()
    }
}
