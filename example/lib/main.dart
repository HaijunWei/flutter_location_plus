import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:location_plus/location_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final locationPlus = LocationPlus();

  void _start() async {
    final status = await Permission.location.request();
    log('$status');
    locationPlus.startUpdatingLocation();
  }

  void _startSingle() async {
    final status = await Permission.location.request();
    log('$status');
    final location = await locationPlus.requestSingleLocation();
    locationPlus.reverseGeo(location).then((value) {
      for (var e in value) {
        log('${e?.country} ${e?.locality} ${e?.subLocality}');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    locationPlus.locationUpdated.listen((event) {
      log('${event.latitude}, ${event.longitude}');
      locationPlus.reverseGeo(event).then((value) {
        for (var e in value) {
          log('${e?.country} ${e?.locality} ${e?.subLocality}');
        }
      });
    });

    _startSingle();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(),
      ),
    );
  }
}
