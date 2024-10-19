import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:habiter_/providers/habit_provider.dart';
import 'package:habiter_/screens/splash.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitsProvider(),
      child: const MyApp(),
    )
  );
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