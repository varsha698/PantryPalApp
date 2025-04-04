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
      print("Picked image: ${pickedFile.path}");
      setState(() => _image = File(pickedFile.path));
    } else {
      print("No image selected.");
    }
  }

  Future<void> _uploadPost() async {
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
        print("Uploading image...");
        String imageId = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('community_images')
            .child('$imageId.jpg');

        UploadTask uploadTask = ref.putFile(_image!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();

        print("Image successfully uploaded! URL: $imageUrl");
      }

      await FirebaseFirestore.instance.collection('community_posts').add({
        'author': FirebaseAuth.instance.currentUser?.displayName ??
            FirebaseAuth.instance.currentUser?.email ??
            "Anonymous",
        'content': _contentController.text.trim(),
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Post uploaded to Firestore");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created yay successfully!")),
      );

      setState(() {
        _contentController.clear();
        _image = null;
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error uploading post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to post. Try again when you are better.")),
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
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          if (_image != null)
            Column(
              children: [
                Image.file(_image!, height: 200, fit: BoxFit.cover),
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
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  onPressed: _uploadPost,
                  icon: const Icon(Icons.send),
                  label: const Text("Post"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
        ]),
      ),
    );
  }
}