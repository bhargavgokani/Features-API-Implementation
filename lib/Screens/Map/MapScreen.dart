import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int markerId = 1;
  List<dynamic> map = [];
  Future<void> localData() async {
    var data = await rootBundle.loadString("assets/data.json");
    setState(() {
      map = json.decode(data);
      addDataToMarker();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    localData();
  }

  final List<Marker> marker = [];
  void addDataToMarker() {
    for (int i = 0; i < map.length; i++) {
      marker.add(
        Marker(
          markerId: MarkerId('${markerId + i}'),
          position: LatLng(map[i]['Lat'], map[i]['Long']),
          infoWindow: InfoWindow(title: map[i]['name']),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: LatLng(23.019450, 72.530209), zoom: 13),
          markers: Set<Marker>.of(marker),
        ),
      ),
    );
  }
}
