// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'Stopwatch.dart';
import 'History.dart';

void main() {runApp(MyApp());}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch Example', 
      home: MyHomePage(),
      theme: ThemeData(primarySwatch: Colors.grey),
    );
  }
}


class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        //backgroundColor: const Color(0xFF000000),
        appBar: AppBar( 
          title: const Center (
            child: Text("Run boy!  RUN!!!"),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon : Icon(Icons.directions_bike_sharp)),
              Tab(icon : Icon(Icons.history)),
              Tab(icon : Icon(Icons.settings))
            ],
          ), 
        ),
        body: TabBarView(
          children:[
            StopwatchPage(),
            HistoryPage(),
            SettingsPage(),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    return Column(
      children: const [
        Icon(Icons.directions_transit),
      ],
    );
  }
}

