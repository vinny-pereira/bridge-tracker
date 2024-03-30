import 'dart:async';

import 'package:bridge_tracker/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import '../backend/bridge_data_provider.dart';
import '../backend/notification_work.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, List<BridgeData>>> bridgeData;
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    bridgeData = BridgeDataProvider().fetchBridgeData();
    startPeriodicUpdate();
  }

  void startPeriodicUpdate() {
    updateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      setState(() {
        bridgeData = BridgeDataProvider().fetchBridgeData();
      });
    });
  }

  Future<void> refreshBridgeData() async {
    setState(() {
      bridgeData = BridgeDataProvider().fetchBridgeData();
    });
    await bridgeData;
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bridge Status'),
      ),
      body: FutureBuilder<Map<String, List<BridgeData>>>(
        future: bridgeData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Wrap ListView.builder inside a RefreshIndicator
            return RefreshIndicator(
              onRefresh: refreshBridgeData,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  String key = snapshot.data!.keys.elementAt(index);
                  List<BridgeData> bridges = snapshot.data![key]!;
                  return ExpansionTile(
                    title: Text(key),
                    children: bridges.map((bridge) => BridgeCard(bridge: bridge)).toList(),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class BridgeCard extends StatelessWidget {
  final BridgeData bridge;

  BridgeCard({required this.bridge});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.error;
    Color color = Colors.red;

    switch (bridge.color) {
      case BridgeColor.green:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case BridgeColor.amber:
        icon = Icons.warning_amber_outlined;
        color = Colors.amber;
        break;
      case BridgeColor.red:
        icon = Icons.cancel_outlined;
        color = Colors.red;
        break;
    }

    return Card(
      child: ListTile(
        leading: Icon(icon),
        iconColor: color,
        title: Text(bridge.title ?? ''),
        subtitle: Text(bridge.description ?? ''),
      ),
    );
  }
}