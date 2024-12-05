import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_signup/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ...
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      home: Wrapper(),
    );
  }
}
