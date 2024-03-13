import 'package:flutter/material.dart';
import 'dart:async';

class Bridge extends StatefulWidget{
  @override
  _CustomBridgeState createState() => _CustomBridgeState();
}

class _CustomBridgeState extends State<Bridge>{
  late String title;
  late String description;
  late IconData icon;

  @override
  void initState() {
    super.initState();
    // Initialize content
    updateContent();
    // Update content periodically
    Timer.periodic(Duration(minutes: 5), (timer) {
      updateContent();
    });
  }

  void updateContent() {
    // Your logic to update title, description, and icon
    setState(() {
      title = "New Title";
      description = "New Description";
      icon = Icons.account_balance_wallet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}