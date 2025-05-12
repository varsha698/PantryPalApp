import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'PostScreen.dart';
import 'chat_screen.dart';
import 'comment_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Future<void> _likePost(String postId, List likes) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final postRef =
        FirebaseFirestore.instance.collection('community_posts').doc(postId);

    if (likes.contains(currentUserId)) {
      await postRef.update({'likes': FieldValue.arrayRemove([currentUserId])});
    } else {
      await postRef.update({'likes': FieldValue.arrayUnion([currentUserId])});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Food Community"), actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostScreen()),
            );
          },
        ),
      ]),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('community_posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final data = post.data() as Map<String, dynamic>;
                    final likes = data['likes'] ?? [];
                    final timestamp = data['timestamp']?.toDate();

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const CircleAvatar(),
                            title: Text(data['author'] ?? 'Unknown'),
                            subtitle: Text(
                              timestamp != null
                                  ? timeago.format(timestamp)
                                  : 'Just now',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          if (data['imageUrl'] != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  minHeight: 200,
                                  maxHeight: 300,
                                ),
                                child: Image.network(
                                  data['imageUrl'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const SizedBox(
                                      height: 200,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 80),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              data['content'] ?? '',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  IconButton(
                                    icon: Icon(
                                      likes.contains(FirebaseAuth
                                              .instance.currentUser?.uid)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: likes.contains(FirebaseAuth
                                              .instance.currentUser?.uid)
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () =>
                                        _likePost(post.id, likes),
                                  ),
                                  Text('${likes.length}',
                                      style:
                                          const TextStyle(fontSize: 13)),
                                  IconButton(
                                    icon: const Icon(Icons.comment),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CommentScreen(postId: post.id),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {
                                      final content = data['content'] ?? '';
                                      Share.share(content);
                                    },
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16, bottom: 10),
                            child: Text(
                              "${likes.length} likes",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
              child: const Text("Join the Community Chat Group"),
            ),
          )
        ],
      ),
    );
  }
}
