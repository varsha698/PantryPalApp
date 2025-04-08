import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController phoneController;
  late TextEditingController pronounsController;

  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    if (userId == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final data = doc.data();
    if (data != null) {
      setState(() {
        firstNameController = TextEditingController(text: data['firstName'] ?? '');
        lastNameController = TextEditingController(text: data['lastName'] ?? '');
        emailController = TextEditingController(text: data['email'] ?? '');
        usernameController = TextEditingController(text: data['username'] ?? '');
        phoneController = TextEditingController(text: data['phone'] ?? '');
        pronounsController = TextEditingController(text: data['pronouns'] ?? '');
      });
    }
  }

  Future<void> _saveProfile() async {
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'username': usernameController.text.trim(),
      'phone': phoneController.text.trim(),
      'pronouns': pronounsController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    setState(() => isEditing = false);
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
            ),
            const SizedBox(height: 8),
            const Text("Change Photo", style: TextStyle(color: Colors.blue)),

            const SizedBox(height: 24),
            _buildTextField("First Name", firstNameController, readOnly: !isEditing),
            _buildTextField("Last Name", lastNameController, readOnly: !isEditing),
            _buildTextField("Email Address", emailController, readOnly: true),
            _buildTextField("Username", usernameController, readOnly: !isEditing),
            _buildTextField("Phone Number", phoneController, readOnly: !isEditing),
            _buildTextField("Pronouns", pronounsController, readOnly: !isEditing),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  _saveProfile();
                } else {
                  setState(() => isEditing = true);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.blue,
              ),
              child: Text(isEditing ? "Save Profile" : "Edit Profile"),
            )
          ],
        ),
      ),
    );
  }
}
