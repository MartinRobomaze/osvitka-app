import 'dart:async';

import 'package:flutter/material.dart';
import 'package:osvitka/client.dart';
import 'package:duration_picker/duration_picker.dart';
import 'dart:developer';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Osvitka controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Duration timeToSet = const Duration();

class _MyHomePageState extends State<MyHomePage> {
  late OsvitkaClient client;
  late Future<OsvitkaStatus> status;

  bool turnedOffFlag = false;

  void getOsvitkaStatus() {
    setState(() {
      status = client.getStatus();
    });
  }
  
  void turnOn() {
    setState(() {
      var exposureTime = timeToSet.inSeconds;
      var power = 65535;
      var LEDStatus = "on";

      status = client.setStatus(OsvitkaStatus(
        exposureTime: exposureTime,
        power: power,
        status: LEDStatus,
      ));

      Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          timeToSet = Duration(seconds: timeToSet.inSeconds - 1);
        });

        if (timeToSet.inSeconds < 0 || turnedOffFlag) {
          timer.cancel();
          turnedOffFlag = false;

          setState(() {
            status = Future(() => const OsvitkaStatus(
              exposureTime: 0,
              power: 0,
              status: "off"));
            }
          );
        }
      });
    });
  }

  void turnOff() {
    turnedOffFlag = true;
    setState(() {
      status = client.setStatus(const OsvitkaStatus(
        exposureTime: 0,
        power: 0,
        status: "off",
      )
      );
    });
  }

  @override
  void initState() {
    super.initState();
    client = OsvitkaClient("192.168.4.1");
    status = client.getStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: getOsvitkaStatus,
              icon: const Icon(Icons.refresh)
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Duration Picker(
              duration: timeToSet,
              baseUnit: BaseUnit.second,
              onChange: (val) {
                setState(() => timeToSet = val);
              },
              snapToMins: 5.0,
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: turnOn,
                        child: const Text('TURN ON'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.exposure_zero),
                        onPressed: () {
                          setState(() {
                            timeToSet = const Duration();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: turnOff,
                        child: const Text('TURN OFF'),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: FutureBuilder<OsvitkaStatus>(
                    future: status,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          "Current status: ${snapshot.data!.status}",
                          style: Theme.of(context).textTheme.headline4,
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error ${snapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
