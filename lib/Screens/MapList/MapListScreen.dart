// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import 'OpenMapScreen.dart';
//
// class Maplistscreen extends StatefulWidget {
//   const Maplistscreen({super.key});
//
//   @override
//   State<Maplistscreen> createState() => _MaplistscreenState();
// }
//
// class _MaplistscreenState extends State<Maplistscreen> {
//   List<dynamic> map = [];
//   bool thisAppClick = false;
//   var valueOflongitude;
//   var valueOflatitude;
//
//   Future<void> localData() async {
//     var data = await rootBundle.loadString("assets/data.json");
//     setState(() {
//       map = json.decode(data);
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     localData();
//   }
//
//   final Location location = Location();
//
//   Future<bool> checkServiceAvailability() async {
//     bool isEnable = await location.serviceEnabled();
//     if (isEnable) {
//       return true;
//     }
//     isEnable = await location.requestService();
//     if (isEnable) {
//       return true;
//     }
//     return false;
//   }
//
//   Future<Position> getUserLocation() async {
//     await Geolocator.requestPermission()
//         .then((value) {})
//         .onError((e, stackTrace) {
//       print("error$e");
//     });
//     return await Geolocator.getCurrentPosition();
//   }
//
//   Future<bool> checkPermission(Permission permission) async {
//     final status = await permission.request();
//
//     if (status.isGranted && await checkServiceAvailability()) {
//       return true;
//     } else {
//       print(status);
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please turn on your location')));
//       return false;
//     }
//   }
//
//   void onThisAPP() async {
//     thisAppClick = await checkPermission(Permission.location);
//     var value = await getUserLocation();
//     valueOflatitude = value.latitude;
//     valueOflongitude = value.longitude;
//   }
//
//   static void navigateTo(double lat, double lng) async {
//     var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
//     if (await canLaunch(uri.toString())) {
//       await launch(uri.toString());
//     } else {
//       throw 'Could not launch ${uri.toString()}';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(
//             Icons.arrow_back_outlined,
//             color: Colors.white,
//           ),
//         ),
//         title: const Text(
//           "Places",
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFF3F5769),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: map.length,
//               itemBuilder: (context, index) {
//                 final post = map[index];
//                 return Card(
//                   elevation: 4,
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       child: Text((index + 1).toString()),
//                     ),
//                     title: Text(
//                       post['name'],
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     onTap: () {
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             title: const Text("Open in .... "),
//                             actions: [
//                               TextButton(
//                                   onPressed: () {
//                                     navigateTo(post['Lat'], post['Long']);
//                                     Navigator.pop(context); // Close the dialog
//                                   },
//                                   child: const Text("Google Map")),
//                               TextButton(
//                                   onPressed: () async {
//                                     onThisAPP();
//                                     if (thisAppClick) {
//                                       if (context.mounted) {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => OpenLocation(
//                                                 valueOflongitude,
//                                                 valueOflatitude),
//                                           ),
//                                         );
//                                         Navigator.pop(
//                                             context); // Close the dialog
//                                       }
//                                     }
//                                     print("ans......$thisAppClick");
//                                     print(context.mounted);
//                                     Navigator.pop(context); // Close the dialog
//                                   },
//                                   child: const Text("in this app")),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'OpenMapScreen.dart'; // Your OpenLocation screen file

class Maplistscreen extends StatefulWidget {
  const Maplistscreen({Key? key}) : super(key: key);

  @override
  State<Maplistscreen> createState() => _MaplistscreenState();
}

class _MaplistscreenState extends State<Maplistscreen> {
  List<dynamic> locations = [];
  late double currentLatitude;
  late double currentLongitude;

  final Location location = Location();

  @override
  void initState() {
    super.initState();
    loadLocalData();
  }

  Future<void> loadLocalData() async {
    final data = await rootBundle.loadString("assets/data.json");
    setState(() {
      locations = json.decode(data);
    });
  }

  Future<bool> checkAndRequestPermission() async {
    final locationPermission = await Permission.location.request();
    final isServiceEnabled =
        await location.serviceEnabled() || await location.requestService();

    if (locationPermission.isGranted && isServiceEnabled) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location permissions or service is not enabled.")),
      );
      return false;
    }
  }

  Future<void> fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      currentLatitude = position.latitude;
      currentLongitude = position.longitude;
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> openGoogleMap(double lat, double lng) async {
    final uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch Google Maps with $uri';
    }
  }

  void showOptionBottomSheet(BuildContext context, double lat, double lng) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text("Open in Google Maps"),
                onTap: () {
                  Navigator.pop(context);
                  openGoogleMap(lat, lng);
                },
              ),
              ListTile(
                leading: const Icon(Icons.app_settings_alt),
                title: const Text("Open in This App"),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  bool permissionGranted = await checkAndRequestPermission();
                  if (permissionGranted) {
                    await fetchUserLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OpenLocation(
                          userlat: currentLatitude,
                          userlong: currentLongitude,
                          deslat: lat,
                          deslong: lng,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
        ),
        title: const Text("Places", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F5769),
      ),
      body: locations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text((index + 1).toString()),
                    ),
                    title: Text(
                      location['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () => showOptionBottomSheet(
                      context,
                      location['Lat'],
                      location['Long'],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
