// ignore_for_file: use_key_in_widget_constructors
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/round-button.dart';
import "package:flutter_ringtone_player/flutter_ringtone_player.dart";
import 'package:http/http.dart' as http;
import 'dart:io';

double roundDouble(double value, int places){ 
   num mod = pow(10.0, places); 
   return ((value * mod).round().toDouble() / mod); 
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'tryouts',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return DefaultTabController(
      length: 2,
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
            ],
          ), 
        ),
        body: TabBarView(
          children:[
            DirectRun(),
            History(),
          ],
        ),
      ),
    );
  }
}

class DirectRun extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: CountdownPageState(),
    );
  }

}

class History extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    return Column(
      children: const [
        Icon(Icons.directions_transit),
      ],
    );
  }
}



class CountdownPageState extends StatefulWidget {
  @override
  State<CountdownPageState> createState() => _CountdownPageStateState();
}

class _CountdownPageStateState extends State<CountdownPageState> with TickerProviderStateMixin{
  late AnimationController controller;
  
  Location locate = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  bool serviceEnabled = false;
  late PermissionStatus permissionGranted;
  double d = 0.0;
  String v = '00.00';
  double departn = 0, N = 0;
  double departw = 0, W = 0;
  bool isPlaying = false;
  bool permitted = false;
  
  Future<http.Response> createAlbum() async {
    debugPrint("hello1");
    return http.post(
      Uri.parse('http://yakuru43.pythonanywhere.com/test/'),
      headers:{
        "Content-Type": "application/x-www-form-urlencoded",

      },
      body: {
        "id_user": "12345",
        "vitesse": v.toString(),
        "latitude" : N.toString(),
        "longitude" : W.toString(),
        "distance" : d.toString(),
        "hauteur" :"5896",
        "duree" :"01254",
      }
    );
  }
  String get countText {
    Duration count = controller.duration! * controller.value;
    return controller.isDismissed
        ? '${controller.duration!.inHours}:${(controller.duration!.inMinutes % 60).toString().padLeft(2, '0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '${count.inHours}:${(count.inMinutes % 60).toString().padLeft(2, '0')}:${(count.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  double progress = 1.0;

  void notify() {
    if (countText == '00:00:00') {
      FlutterRingtonePlayer.playNotification();
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    if((lat1 == 0) & (lon1 == 0)){
      return 0;
    } 
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  // ignore: non_constant_identifier_names
  void get_permission() async {
    serviceEnabled = await locate.requestService();
    if(serviceEnabled){
      permissionGranted = await locate.requestPermission();
      if (permissionGranted == PermissionStatus.granted) {
        final LocationData data = await locate.getLocation();
        departn = data.latitude!;
        departw = data.longitude!;
        permitted = true;
      }
    }    
  }

  Future<void> _listenLocation() async {
    debugPrint("hello1");
    _locationSubscription = locate.onLocationChanged.handleError((onError) {
      debugPrint(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((LocationData currentlocation) async {
      v = currentlocation.speed!.toStringAsFixed(2);
      N = currentlocation.latitude!;
      W = currentlocation.longitude!;
      d = roundDouble(calculateDistance(departn, departw, N, W), 2);
      debugPrint("hello2");
    });
  }

  void reset_(){
    _locationSubscription!.cancel();
    setState(() {
      debugPrint("hello");
      _locationSubscription = null;
    });
    d = 0.0;
    v = '00.00';
    N = 0.0;
    W = 0.0;
    departn = 0;
    departw = 0;
    progress = 1.0;
    isPlaying = false;
  }

  @override
  void initState() {
    super.initState();
    get_permission();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );

    controller.addListener(() {
      notify();
      if (controller.isAnimating) {
        setState(() {
          if (permitted == true){
            _listenLocation();
            progress = controller.value;
          }else{
            setState(() {
              reset_();
              controller.reset();
              final snackBar = SnackBar(
                content: const Text('Please head to settings and give us permission.'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    //nothing
                  },
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });
          }
        });
      } else {
        setState(() {
          //reset_();
          progress = 1.0;
          isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //const Color(0xFF000000)
      backgroundColor: const Color(0xFF000000) ,
      body: Column(
        children: [
          Container(
            color: const Color(0xFF000000),
            padding: const EdgeInsets.all(20.0),
            child: Table(
              border: TableBorder.all(color: Colors.black),
              children: [
                const TableRow(children: [
                  Center (
                    child: Text('Vitesse',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Center (
                    child : Text('Position',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Center(
                    child : Text('Distance',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 25,
                      ),
                    ),
                  )
                ]),
                TableRow(children: [
                  Center(
                    child : Text(v + 'km/h',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Center(
                    child : Text(N.toString() + '" N',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Center(
                    child : Text(d.toString() + 'km',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ]),
                TableRow(children: [
                  const Text(''),
                  Center(
                    child : Text(W.toString() + '" W',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Text(''),
                ])               
              ],
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                    backgroundColor: Colors.orangeAccent,
                    value: progress,
                    strokeWidth: 6,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (controller.isDismissed) {
                      showModalBottomSheet(
                        backgroundColor: Colors.grey,
                        context: context,
                        builder: (context) => SizedBox(
                          height: 200,
                          child: CupertinoTimerPicker(
                            backgroundColor: Colors.grey,
                            initialTimerDuration: controller.duration!,
                            onTimerDurationChanged: (time) {
                              setState(() {
                                controller.duration = time;
                              });
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) => Text(
                      countText,
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (controller.isAnimating) {
                      controller.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      controller.reverse(
                          from: controller.value == 0 ? 1.0 : controller.value);
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  child: RoundButton(
                    icon: isPlaying == true ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    controller.reset();
                    reset_();
                    setState(() {
                      isPlaying = false;
                    });
                  },
                  child: const RoundButton(
                    icon: Icons.stop,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}