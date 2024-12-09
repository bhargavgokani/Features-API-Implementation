import 'package:flutter/material.dart';

class OpenLocation extends StatefulWidget {
  const OpenLocation(lat, long, {super.key});

  @override
  State<OpenLocation> createState() => _OpenLocationState();
}

class _OpenLocationState extends State<OpenLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
