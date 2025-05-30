import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //khoa dọc màn hình
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // chỉ cho dọc
  ]);
  runApp(
    MaterialApp(
      
      home:  ProcessSccreen(email: "phuckk215@gmail.com",),
      debugShowCheckedModeBanner: false,
    ),
  );
}
