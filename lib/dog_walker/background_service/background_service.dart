import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

void onStart(ServiceInstance service) {
  String? walkId;
  if (walkId == null) return;

  service.on('setData').listen((event) {
    walkId = event?['walkId'];
  });

  Timer.periodic(const Duration(seconds: 6), (timer) async {

    if (!(await Geolocator.isLocationServiceEnabled())) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final ref = FirebaseDatabase.instance.ref('walk_locations/$walkId');
    await ref.update({
      'lat': position.latitude,
      'lng': position.longitude,
    });
  });
}

