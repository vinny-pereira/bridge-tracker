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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  NotificationWork.initNotifications();
  runApp(const MyApp());
  Workmanager().registerOneOffTask(
    "2",
    NotificationWork.notificationTaskName,
  );
  Workmanager().registerPeriodicTask(
    "1",
    NotificationWork.notificationTaskName,
  );
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