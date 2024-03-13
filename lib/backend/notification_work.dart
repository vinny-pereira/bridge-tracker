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

  static Future<void> fetchBridgeDataAndNotify(inputData) async {
    try {
      final bridgeData = await BridgeDataProvider().fetchBridgeData();

      var notificationId = inputData[notificationTaskName];
      var bridgeSelectionData = await DatabaseHelper.fetchNotificationsByNotificationId(notificationId);
      var message = "";

      bridgeData.values.first.forEach((data) {
        if (bridgeSelectionData.any((bridge) => bridge.bridge == data.title))
          return;

        message += "${data.title}: ${data.description}";
      });

      String notificationTitle = "Bridge Update";
      String notificationBody = message;

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