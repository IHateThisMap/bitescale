package com.example.flutter_calorie_couinter_exercise_app

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Passes food files that are opened with BiteScale, or shared to it, on to
 * the Flutter side (see lib/services/incoming_files.dart).
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    /** A file the app was started with, until Flutter asks for it. */
    private var initialFile: ByteArray? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        initialFile = readFile(intent)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "bitescale/incoming_file",
        ).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "takeInitialFile") {
                    result.success(initialFile)
                    initialFile = null
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    /** A file opened or shared while the app is already running. */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val bytes = readFile(intent) ?: return
        channel?.invokeMethod("fileReceived", bytes)
    }

    private fun readFile(intent: Intent?): ByteArray? {
        if (intent == null) return null
        // Reopening the app from the recent apps list repeats the intent
        // it was started with; don't import the same file again.
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) {
            return null
        }
        val uri: Uri = when (intent.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND ->
                if (Build.VERSION.SDK_INT >= 33) {
                    intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra(Intent.EXTRA_STREAM)
                }
            else -> null
        } ?: return null
        return try {
            contentResolver.openInputStream(uri)?.use { it.readBytes() }
        } catch (e: Exception) {
            null
        }
    }
}
