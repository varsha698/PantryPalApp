import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:login_page/screens/PostScreen.dart';
import 'package:login_page/screens/chat_screen.dart';
import 'package:login_page/screens/comment_screen.dart'; 

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Future<void> _likePost(String postId, List likes) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final postRef = FirebaseFirestore.instance.collection('community_posts').doc(postId);

    if (likes.contains(currentUserId)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([currentUserId]),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([currentUserId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Community"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
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

                var posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    var data = post.data() as Map<String, dynamic>;

                    List likes = data['likes'] ?? [];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const CircleAvatar(),
                            title: Text(data['author'] ?? 'Unknown User'),
                            subtitle: Text(
                              data['timestamp'] != null
                                  ? data['timestamp'].toDate().toString()
                                  : '',
                            ),
                          ),
                          if (data['imageUrl'] != null)
                            Image.network(data['imageUrl']),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(data['content']),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(
                                  likes.contains(FirebaseAuth.instance.currentUser?.uid)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: likes.contains(FirebaseAuth.instance.currentUser?.uid)
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () => _likePost(post.id, likes),
                              ),
                              IconButton(
                                icon: const Icon(Icons.comment),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CommentScreen(postId: post.id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  final postContent = data['content'] ?? '';
                                  Share.share(postContent);
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: Text("${likes.length} likes", style: const TextStyle(fontSize: 12)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Join the Community Chat Group"),
            ),
          ),
        ],
      ),
    );
  }
}
