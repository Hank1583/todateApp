import 'package:flutter/material.dart';

void main() => runApp(const SmokeTestApp());

class SmokeTestApp extends StatelessWidget {
  const SmokeTestApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.deepPurple,
        body: Center(
          child: Text(
            'BOOT OK',
            style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
