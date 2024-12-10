import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'home.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}
