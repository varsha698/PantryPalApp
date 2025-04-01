import 'package:flutter/material.dart';
import 'package:login_page/screens/profile_screen.dart'; // 👈 Import your Profile screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PantryPal Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          )
        ],
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
