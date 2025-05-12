import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _uploadPost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (_contentController.text.trim().isEmpty && _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write something or add an image.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? imageUrl;

    try {
      if (_image != null) {
        String imageId = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('community_images')
            .child('$imageId.jpg');

        UploadTask uploadTask = ref.putFile(_image!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();
      final username = userData?['username'] ?? currentUser.email?.split('@').first ?? 'Unknown';

      await FirebaseFirestore.instance.collection('community_posts').add({
        'author': username,
        'content': _contentController.text.trim(),
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully!")),
      );

      setState(() {
        _contentController.clear();
        _image = null;
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_image != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _image!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: 240,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _image = null),
                    icon: const Icon(Icons.cancel),
                    label: const Text("Remove Image"),
                  ),
                ],
              )
            else
              TextButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Upload Image"),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _uploadPost,
                      icon: const Icon(Icons.send),
                      label: const Text("Post"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
