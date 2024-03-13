import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

import '../backend/bridge_data_provider.dart';
import '../backend/database_helper.dart';
import '../backend/notification_work.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _selectedTime = DateTime.now();
  final _selectedBridges = <String>[];
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var uuid = const Uuid();
  var bridges = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
      ),
      body: Column(
        children: <Widget>[
          Text('Select time for notification:'),
          TimePickerSpinner(
            is24HourMode: false,
            normalTextStyle: const TextStyle(fontSize: 24, color: Colors.black38),
            highlightedTextStyle: const TextStyle(fontSize: 24, color: Colors.pinkAccent),
            spacing: 50,
            itemHeight: 80,
            isForce2Digits: true,
            onTimeChange: (time) {
              setState(() {
                _selectedTime = time;
              });
            },
          ),
          MultiSelectDialogField(
            listType: MultiSelectListType.CHIP,
            onConfirm: (newValues) {
              setState(() {
                _selectedBridges.clear();
                if(newValues.isNotEmpty) {
                  _selectedBridges.addAll(newValues);
                }
              });
            },
            items: bridges.map<MultiSelectItem<String>>((String value) {
              return MultiSelectItem<String>(
                value,
                value,
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () {
              // Logic to schedule the notification
              scheduleNotification(_selectedTime, _selectedBridges);
            },
            child: Text('Set Notification'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    fetchBridgeDataAndPopulate();
  }

  void initializeNotifications() {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> fetchBridgeDataAndPopulate() async {
    var data = await BridgeDataProvider().fetchBridgeData();
    setState(() {
      data.values.first.where((bridge) => bridge.title != null).forEach((bridge) => bridges.add(bridge.title ?? ""));
    });
  }

  void scheduleNotification(DateTime time, List<String> bridges) async {

    var notificationId = uuid.v4();

    bridges.forEach((bridge) async {
      var notification = BridgeNotification(bridge: bridge, time: time.toIso8601String(), notificationId: notificationId);
      await DatabaseHelper.createNotification(notification);
    });

    final bridgeSelectionData = <String, dynamic>{
      NotificationWork.notificationTaskName: notificationId
    };

    Workmanager().registerOneOffTask(
      NotificationWork.notificationTaskName,
      "fetchBridgeDataAndNotify",
      inputData: bridgeSelectionData,
      initialDelay: Duration(seconds: time.difference(DateTime.now()).inSeconds),
    );
  }
}

class BridgeSelectionData{
  final List<String> bridges;
  final String time;
  final String notificationId;

  BridgeSelectionData({required this.bridges, required this.time, required this.notificationId});
}