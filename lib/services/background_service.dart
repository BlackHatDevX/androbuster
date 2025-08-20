import 'package:flutter/services.dart';
import 'dart:async';

class BackgroundService {
  Timer? _keepAliveTimer;
  static const MethodChannel _platform = MethodChannel('com.blackhatdevx.androbuster/service');

  Future<void> startService() async {
    try {

      _keepAliveTimer?.cancel();
      _keepAliveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        print('Keep-alive ping - scanning is active');

      });

      try {
        await _platform.invokeMethod('startForegroundService');
        print('Native foreground service started successfully');
      } catch (e) {
        print('Failed to start native service: $e');
        print('Using timer-based background execution as fallback');
      }

      print('Background service started');
    } catch (e) {
      print('Failed to start background service: $e');
    }
  }

  Future<void> stopService() async {
    try {

      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;

      try {
        await _platform.invokeMethod('stopForegroundService');
        print('Native foreground service stopped successfully');
      } catch (e) {
        print('Failed to stop native service: $e');
      }

      print('Background service stopped');
    } catch (e) {
      print('Failed to stop background service: $e');
    }
  }

  bool get isRunning => _keepAliveTimer?.isActive ?? false;

  void dispose() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }
}