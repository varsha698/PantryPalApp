import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PantryPal Home'),
      ),
      body: const Center(
        child: Text(
          'Welcome to PantryPal!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
