import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'env.dart';

void main() {
  runApp(const AmeyaApp());
}

class AmeyaApp extends StatelessWidget {
  const AmeyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ameya - Boundless Careness',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}