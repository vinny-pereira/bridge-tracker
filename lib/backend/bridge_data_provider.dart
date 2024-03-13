import 'package:chaleno/chaleno.dart';
import 'package:flutter/material.dart';

class BridgeDataProvider {

  static const source = 'https://seaway-greatlakes.com/bridgestatus/detailsnai?key=BridgeSCT';
  static const defaultTitle = 'St. Catharines/ Thorold';

  Future<Map<String, List<BridgeData>>> fetchBridgeData() async {
    var parser = await Chaleno().load(source);

    if (parser == null) throw Exception('Failed to load data');

    final key = parser.getElementsByTagName("title")?.first.innerHTML ?? defaultTitle;
    final rows = parser.getElementsByTagName("tr");

    if(rows == null || rows.isEmpty) throw Exception('Failed to load data');

    var result = Map<String, List<BridgeData>>();
    result[key] = [];

    for(final row in rows){
      var data = row.querySelectorAll('td');
      if(data == null || data.length != 2) continue;

      var img = data.first.querySelector('img')?.src;
      var text = data.elementAt(1).querySelectorAll('span');

      if(text == null) continue;
      result[key]?.add(BridgeData(title:text.first.innerHTML, description: text.elementAt(1).innerHTML, color: _getBridgeColor(img)));
    }

    return result;
  }

  BridgeColor _getBridgeColor(String? text){
    if(text == null) {
      return BridgeColor.red;
    }
    else if(text.contains('green')){
      return BridgeColor.green;
    }
    else if(text.contains('amber')){
      return BridgeColor.amber;
    }
    else{
      return BridgeColor.red;
    }
  }
}

class BridgeData{
  final String? title;
  final String? description;
  final BridgeColor color;

  BridgeData({
    required this.title,
    required this.description,
    required this.color,
  });
}

enum BridgeColor{
  green,
  amber,
  red
}