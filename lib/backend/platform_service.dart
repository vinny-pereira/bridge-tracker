import 'dart:async';
import 'package:flutter/services.dart';

class PlatformService {
  static const MethodChannel _channel = MethodChannel('com.example.bridge_tracker');

  static Future<void> scheduleNotification(DateTime dateTime, String bridgeId) async {
    try {
      await _channel.invokeMethod('scheduleNotification', {
        'dateTime': dateTime.millisecondsSinceEpoch,
        'bridgeId': bridgeId,
      });
    } on PlatformException catch (e) {
      print("Failed to schedule notification: '${e.message}'.");
    }
  }
}