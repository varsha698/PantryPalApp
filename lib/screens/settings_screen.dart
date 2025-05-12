import 'package:flutter/material.dart';
import 'package:login_page/screens/home_screen.dart';
import 'package:login_page/screens/community_screen.dart';
import 'package:login_page/screens/organization_screen.dart';
import 'package:login_page/screens/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CommunityScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrganizationScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.orange.shade100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: const [
          SettingsSectionTitle(title: 'GENERAL'),
          SettingsItem(icon: Icons.person, title: 'Account'),
          SettingsItem(icon: Icons.notifications, title: 'Notifications'),
          SettingsItem(icon: Icons.local_offer, title: 'Coupons'),
          SettingsItem(icon: Icons.logout, title: 'Logout'),
          SettingsItem(icon: Icons.delete, title: 'Delete Account'),
          SettingsSectionTitle(title: 'FEEDBACK'),
          SettingsItem(icon: Icons.bug_report, title: 'Report a bug'),
          SettingsItem(icon: Icons.feedback, title: 'Send feedback'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile tab is selected
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Organizations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const SettingsItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepOrange),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // TODO: Add navigation logic for each setting item
      },
    );
  }
}
