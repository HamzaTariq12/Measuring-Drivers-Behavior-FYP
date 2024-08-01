import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double ax = 0, ay = 0, az = 0, gx = 0, gy = 0, gz = 0;
  String drivingStyle = '';
  Timer? _timer;

  Future<void> sendSensorData() async {
    const url = 'http://192.168.0.102/api/predict/';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'AccX': '$ax',
      'AccY': '$ay',
      'AccZ': '$az',
      'GyroX': '$gx',
      'GyroY': '$gy',
      'GyroZ': '$gz',
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    final responseData = json.decode(response.body);
    final drivingStyle = responseData['Driving Style'];
    print('Driving Style: $drivingStyle');
    setState(() {
      print(gx);
      this.drivingStyle = drivingStyle;
    });
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      sendSensorData(); // call the sendSensorData function every 2 seconds
    });
  }

  void stopTimer() {
    _timer?.cancel(); // cancel the timer if it is not null
    _timer = null;
  }

  @override
  void initState() {
    gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        // print(event);
        setState(() {
          gx = event.x;
          gy = event.y;
          gz = event.z;
        });
      },
    );
    userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        // print(event);
        setState(() {
          ax = event.x;
          ay = event.y;
          az = event.z;
        });
      },
    );
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gyroscope + Accelerometer Sensor"),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.red,
              child: Column(
                children: [
                  const Text('GYROSCOPE'),
                  Text(
                    "X : $gx",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    "Y : $gy",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    "Z : $gz",
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.blue,
              child: Column(
                children: [
                  const Text('ACCELERATION'),
                  Text(
                    "X : $ax",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    "Y : $ay",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    "Z : $az",
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Text(
              "Driving Style: \n$drivingStyle",
              style: const TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
