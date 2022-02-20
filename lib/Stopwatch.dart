// ignore_for_file: use_key_in_widget_constructors, non_constant_identifier_names
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

//Convertir les Millisecondes en format HH/MM/SS
String formatTime(int milliseconds) {
  var secs = milliseconds ~/ 1000;
  var hours = (secs ~/ 3600).toString().padLeft(2, '0');
  var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
  var seconds = (secs % 60).toString().padLeft(2, '0');  
  return "$hours:$minutes:$seconds";
}

//Faire un arrondissement 2 positions aprés la virgule
double roundDouble(double value, int places){ 
   num mod = pow(10.0, places); 
   return ((value * mod).round().toDouble() / mod); 
}

//Calculter la distance entre 2 points de position
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


class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  //Variable pour manipuler le temps
  late Stopwatch _stopwatch;
  late Timer _timer;  
  
  //Variables a monitoriser
  double d = 0.0;
  String v = '00.00';
  double departn = 0, N = 0;
  double departw = 0, W = 0;
  double h = 0;

  //Variables de position
  Location locate = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  bool serviceEnabled = false;
  late PermissionStatus permissionGranted;
  bool permitted = false;

  bool isStopped = false;

  Future<http.Response> report_to_server() {
    debugPrint("sending once every 5 seconds");
    return http.post(
      Uri.parse('http://yakuru43.pythonanywhere.com/test/'),
      headers:{
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body:  jsonEncode({
        "id_user": "12345",
        "vitesse": v.toString(),
        "latitude" : N.toString(),
        "longitude" : W.toString(),
        "distance" : d.toString(),
        "hauteur" : h.toString(),
        "timestamp" : DateTime.now().millisecondsSinceEpoch,
      })
    );
  }

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
      d = d + roundDouble(calculateDistance(departn, departw, N, W), 2);
      departn = N;
      departw = W;
    });
  }

  @override
  void initState() {
    super.initState();
    get_permission();
    _stopwatch = Stopwatch();
    // re-render every 30ms
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }  
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void handleStartStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _locationSubscription!.cancel();
      isStopped = true;
    } else {
      if(permitted){
        _stopwatch.start();
        isStopped = false;
        _listenLocation();
        Timer.periodic(const Duration(seconds: 5), (tick) {
          if (isStopped) {
            tick.cancel();
          }else{
            report_to_server();
          }
        });
        debugPrint("im here");
      }else{
        setState(() {
        reset();
        final snackBar = SnackBar(
          content: const Text('Please head to settings and give us permission.'),
          action: SnackBarAction(
            label: 'Got it!',
            onPressed: () {
              //nothing
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      }

    }
    setState(() {});    // re-render the page
  }  

  void reset() {
    _locationSubscription!.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
    isStopped = true;
    _locationSubscription = null;
    setState(() {} );    // re-render the page
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000) ,
      body:Column(
        children: <Widget>[
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
                ]),
                TableRow(children: [
                  const Text(''),
                  Center(
                    child : Text(h.toString() + '" H',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Text(''),
                ]),                              
              ],
            ),
          ),
          Expanded(
            child: 
              Text(formatTime(_stopwatch.elapsedMilliseconds), style: const TextStyle(color: Colors.orangeAccent ,fontSize: 48.0)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: handleStartStop, child: Text(_stopwatch.isRunning ? 'Pause' : 'Start')),
                ElevatedButton(onPressed: reset, child: const Text('Stop')),
              ],
            )
          )
        ],
      ),
    );
  }
}