import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'direction.dart';

class OpenLocation extends StatefulWidget {
  final double userlat;
  final double userlong;
  final double deslong;
  final double deslat;
  const OpenLocation(
      {required this.userlat,
      required this.userlong,
      required this.deslat,
      required this.deslong,
      super.key});

  @override
  State<OpenLocation> createState() => _OpenLocationState();
}

class _OpenLocationState extends State<OpenLocation> {
  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;

  static const String googleAPIKey = "AlzaSyGhkrStpN8lcbe1VLwqWKGmxNcctTq_NzM";
  static const _baseUrl = 'https://maps.gomaps.pro/maps/api/directions/json?';

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _fetchDirections();
  }

  // Initialize user and destination markers
  void _initializeMarkers() {
    _origin = Marker(
      markerId: const MarkerId('origin'),
      infoWindow: const InfoWindow(title: 'Origin'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: LatLng(widget.userlat, widget.userlong),
    );

    _destination = Marker(
      markerId: const MarkerId('destination'),
      infoWindow: const InfoWindow(title: 'Destination'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: LatLng(widget.deslat, widget.deslong),
    );
  }

  // Fetch directions from Google Maps API
  Future<void> _fetchDirections() async {
    if (_origin == null || _destination == null) return;

    try {
      final directions = await getDirections(
        origin: _origin!.position,
        destination: _destination!.position,
        // googleAPIKey: googleAPIKey,
      );
      setState(() {
        _info = directions;
      });

      if (_info != null) {
        _googleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(_info!.bounds, 100),
        );
      }
    } catch (e) {
      debugPrint('Error fetching directions: $e');
    }
  }

  // Get directions using Google Maps API
  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': googleAPIKey,
      });

      final response = await http.get(uri);
      print('Response body: ${response.body.length}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return Directions.fromMap(data);
        } catch (e) {
          print('Error while parsing JSON: $e');
          return null;
        }
      } else {
        debugPrint('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  // Future<String?> fetchWithRetry(Uri uri, {int retries = 3}) async {
  //   for (int i = 0; i < retries; i++) {
  //     try {
  //       final response = await http.get(uri);
  //       if (response.statusCode == 200 && response.body.isNotEmpty) {
  //         return response.body;
  //       }
  //       print('Retrying... Attempt ${i + 1}');
  //     } catch (e) {
  //       print('Error during attempt ${i + 1}: $e');
  //     }
  //   }
  //   throw Exception('Failed to fetch complete data after $retries retries');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.userlat, widget.userlong),
                zoom: 13,
              ),
              onMapCreated: (controller) => _googleMapController = controller,
              markers: {
                if (_origin != null) _origin!,
                if (_destination != null) _destination!,
              },
              polylines: {
                if (_info != null)
                  Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.blue,
                    width: 5,
                    points: _info!.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
              },
            ),
            if (_info != null)
              Positioned(
                top: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${_info!.totalDistance}, ${_info!.totalDuration}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(widget.userlat, widget.userlong),
              zoom: 13,
            ),
          ),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
