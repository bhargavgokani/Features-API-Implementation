import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'OpenMapScreen.dart';

class Maplistscreen extends StatefulWidget {
  const Maplistscreen({super.key});

  @override
  State<Maplistscreen> createState() => _MaplistscreenState();
}

class _MaplistscreenState extends State<Maplistscreen> {
  List<dynamic> map = [];
  bool thisAppClick = false;
  var valueOflongitude;
  var valueOflatitude;
  Future<void> localData() async {
    var data = await rootBundle.loadString("assets/data.json");
    setState(() {
      map = json.decode(data);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    localData();
  }

  final Location location = Location();

  Future<bool> checkServiceAvailability() async {
    bool isEnable = await location.serviceEnabled();
    if (isEnable) {
      return true;
    }
    isEnable = await location.requestService();
    if (isEnable) {
      return true;
    }
    return false;
  }

  Future<Position> getUserLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((e, stackTrace) {
      print("error$e");
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<bool> checkPermission(Permission permission) async {
    final status = await permission.request();

    if (status.isGranted && await checkServiceAvailability()) {
      return true;
    } else {
      print(status);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please turn on your location')));
      return false;
    }
  }

  void onThisAPP() async {
    thisAppClick = await checkPermission(Permission.location);
    var value = await getUserLocation();
    valueOflatitude = value.latitude;
    valueOflongitude = value.longitude;
  }

  static void navigateTo(double lat, double lng) async {
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Places",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3F5769),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: map.length,
              itemBuilder: (context, index) {
                final post = map[index];
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text((index + 1).toString()),
                    ),
                    title: Text(
                      post['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Open in .... "),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    navigateTo(post['Lat'], post['Long']);
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Text("Google Map")),
                              TextButton(
                                  onPressed: () async {
                                    onThisAPP();
                                    if (thisAppClick) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OpenLocation(
                                              valueOflongitude,
                                              valueOflatitude),
                                        ),
                                      ); // Close the drawer
                                    }
                                    print("ans......$thisAppClick");
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Text("in this app")),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
