// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sqlite.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPage createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  final days = DateFormat('yyyy-MM-dd');
  final hours = DateFormat('hh:mm');

  Map<String, Map<String, dynamic>> distances = {};

  late List<Position> l;
  bool isLoading = false;
  late List<Position> v;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async{
    setState(() {
      isLoading = true;
    });
    v = await DatabaseHelper.instance.queryPosition() as List<Position>;
    
    debugPrint(v.length.toString());

    for ( var i = 0; i < v.length; i++){
      if (distances.containsKey( days.format( DateTime.parse(v[0].Date)) )){
        distances[ days.format( DateTime.parse(v[0].Date)) ]![hours.format( DateTime.parse(v[0].Date))] = v[0].distance;
        debugPrint(v[i].Date);
      }else{
        distances[  days.format( DateTime.parse(v[0].Date)) ] = {};
      }

    }
    debugPrint(distances[days.format( DateTime.parse(v[0].Date))]?.length.toString());    
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center( 
        child: isLoading ? const CircularProgressIndicator( color: Colors.orangeAccent)
          : const Padding(
            padding: EdgeInsets.all(12),
            child: Text("Hello", style: TextStyle(color: Colors.orangeAccent),)
          )
       ,)    
    );
  }
}