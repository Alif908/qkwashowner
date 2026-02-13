import 'package:flutter/material.dart';
import 'package:qkwashowner/vieews/splash_screen.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final bool isTest;

  const MyApp({super.key, this.isTest = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isTest
          ? const Scaffold(body: Center(child: Text('Test Mode')))
          : const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
