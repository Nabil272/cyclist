// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:runboyrun/Auth.dart';
import 'package:runboyrun/HomePage.dart';
import 'Auth.dart';
import 'transition_route_observer.dart';
import 'HomePage.dart';
import 'sqlite.dart';

void main() {runApp(const MyApp());}

class MyApp extends StatelessWidget {
  
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Run Boy! RUN!!!',
      navigatorObservers: [TransitionRouteObserver()],
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        MyHomePage.routeName: (context) => const MyHomePage(),
      },
    );
  }
}


