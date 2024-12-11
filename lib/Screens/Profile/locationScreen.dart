import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMapScreen extends StatefulWidget {
  final double lat;
  final double lng;
  const UserMapScreen({super.key, required this.lat, required this.lng});

  @override
  State<UserMapScreen> createState() => _UserMapScreenState();
}

class _UserMapScreenState extends State<UserMapScreen> {
  late Marker m1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    m1 = Marker(
      markerId: const MarkerId('1'),
      position: LatLng(widget.lat, widget.lng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: LatLng(widget.lat, widget.lng), zoom: 13),
          markers: {m1},
        ),
      ),
    );
  }
}
