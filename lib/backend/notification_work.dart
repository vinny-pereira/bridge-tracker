import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bridge_tracker/backend/bridge_data_provider.dart';

import 'database_helper.dart';

class NotificationWork {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static const String notificationTaskName = 'bridge_tracker_notification_task';
  static const String notificationChanelId = 'bridge_notification_channel';
  static const String notificationChanelName = 'Bridge Notifications';
  static const String notificationChanelDescription = 'Notification channel for bridge updates';

  static Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChanelId,
      notificationChanelName,
      description: notificationChanelDescription,
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> fetchBridgeDataAndNotify() async {
    try {
      final bridgeData = await BridgeDataProvider().fetchBridgeData();

      var message = "";

      for (var data in bridgeData.values.first) {
        if(data.title == null) continue;
        var bridge = await DatabaseHelper.fetchBridgeByName(data.title ?? '');
        if(bridge.isEmpty) {
          await DatabaseHelper.createBridge(BridgeInfo(name: data.title ?? '', color: data.color));
          if(data.color == BridgeColor.green) continue;
          message += "Bridge ${data.title?? ''} ${data.description}\n";
        }
        else{
          if(bridge.first.color == data.color) continue;

          if(bridge.first.color != data.color){
            await DatabaseHelper.updateBridgeColor(bridge.first.id, data.color);
            message += "Bridge ${data.title?? ''} ${data.description}\n";
          }
        }
      }

      var notificationTitle = "Bridge Update";
      var notificationBody = message;

      await _sendNotification(notificationTitle, notificationBody);
    } catch (e) {
      print("Error fetching bridge data: $e");
    }
  }

  static Future<void> _sendNotification(String title, String body) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      notificationChanelId,
      notificationChanelName,
      channelDescription: notificationChanelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}