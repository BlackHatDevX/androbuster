package com.blackhatdevx.androbuster

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import androidx.core.content.ContextCompat

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.blackhatdevx.androbuster/service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startForegroundService" -> {
                    val serviceIntent = Intent(this, AndroBusterService::class.java)
                    ContextCompat.startForegroundService(this, serviceIntent)
                    result.success(null)
                }
                "stopForegroundService" -> {
                    val serviceIntent = Intent(this, AndroBusterService::class.java)
                    stopService(serviceIntent)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
