import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final List<String> badWords = ['fuck', 'shit', 'bitch', 'asshole'];
  String? cachedUsername;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUsername();
    _updateOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateOnlineStatus(true);
    } else {
      _updateOnlineStatus(false);
    }
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'isOnline': isOnline,
      });
    }
  }

  Future<void> _loadUsername() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();
      setState(() {
        cachedUsername = userData?['username'] ?? currentUser.displayName ?? currentUser.email?.split('@').first ?? 'Unknown';
      });
    } catch (e) {
      cachedUsername = 'Unknown';
    }
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    if (_messageController.text.trim().isEmpty && imageUrl == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final text = imageUrl == null ? _filterBadWords(_messageController.text.trim()) : null;

      await FirebaseFirestore.instance.collection('chat_messages').add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'sender': cachedUsername ?? 'Unknown',
        'photoUrl': currentUser.photoURL,
        'uid': currentUser.uid,
        'imageUrl': imageUrl,
        'type': imageUrl != null ? 'image' : 'text',
      });

      _messageController.clear();
      _updateTypingStatus(false);
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final file = File(pickedFile.path);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('chat_images/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}');

    final uploadTask = await storageRef.putFile(file);
    final imageUrl = await uploadTask.ref.getDownloadURL();

    _sendMessage(imageUrl: imageUrl);
  }

  String _filterBadWords(String text) {
    for (String badWord in badWords) {
      text = text.replaceAll(RegExp(badWord, caseSensitive: false), '****');
    }
    return text;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onTyping(String value) {
    _updateTypingStatus(value.isNotEmpty);
  }

  void _updateTypingStatus(bool isTyping) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance.collection('typing_status').doc(currentUser.uid).set({
        'isTyping': isTyping,
      });
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat('h:mm a').format(date);
  }

  Widget _buildMessage(Map<String, dynamic> data, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 18,
              backgroundImage: data['photoUrl'] != null ? NetworkImage(data['photoUrl']) : null,
              backgroundColor: Colors.blueGrey,
              child: data['photoUrl'] == null
                  ? Text(
                      (data['sender'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue[300] : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['sender'] ?? 'Unknown'} ${data['isOnline'] == true ? "🟢" : "🔴"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  if (data['type'] == 'image' && data['imageUrl'] != null)
                    Image.network(
                      data['imageUrl'],
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                  else
                    Text(
                      data['text'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimestamp(data['timestamp']),
                        style: const TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Community Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['uid'] == currentUser?.uid;
                    return _buildMessage(data, isMe);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _onTyping,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
