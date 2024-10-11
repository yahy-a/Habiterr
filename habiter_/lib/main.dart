import 'package:flutter/material.dart';
import 'package:habiter_/screens/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habiter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const SplashScreen(),  
    );
  }
}