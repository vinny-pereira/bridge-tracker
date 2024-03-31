import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:bridge_tracker/backend/notification_work.dart';
import 'package:bridge_tracker/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher(){
  Workmanager().executeTask((task, inputData) async {
    print("Native called background task: $task");
    try{
      if(task == NotificationWork.notificationTaskName)
        await NotificationWork.fetchBridgeDataAndNotify();
      return Future.value(true);
    }catch(e){
      return Future.value(false);
    }
  });
}

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  print("BackgroundFetch headless task: $taskId");
  await NotificationWork.fetchBridgeDataAndNotify();
  BackgroundFetch.finish(taskId);
}

void initPlatformState() {
  if (Platform.isIOS) {
    BackgroundFetch.configure(BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
    ), (String taskId) async {
      print("[BackgroundFetch] Event received: $taskId");
      await NotificationWork.fetchBridgeDataAndNotify();
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
      BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
  } else if (Platform.isAndroid) {
    Workmanager().initialize(callbackDispatcher);
    Workmanager().registerOneOffTask(
      "2",
      NotificationWork.notificationTaskName,
    );
    Workmanager().registerPeriodicTask(
      "1",
      NotificationWork.notificationTaskName,
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationWork.initNotifications();
  initPlatformState();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bridge Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}