import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_page/screens/PostScreen.dart';
import 'package:login_page/screens/chat_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Community"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Posts list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('community_posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var data = posts[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(),
                            title: Text(data['author'] ?? 'Unknown'),
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
                            children: const [
                              Icon(Icons.favorite_border),
                              Icon(Icons.comment),
                              Icon(Icons.share),
                            ],
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
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 1,
      //   onTap: (index) {
      //    
      //   },
      //   selectedItemColor: Colors.orange,
      //   unselectedItemColor: Colors.grey,
      //   // items: const [
      //   //   BottomNavigationBarItem(icon: Icon(Icons.home), label: "Pantry"),
      //   //   BottomNavigationBarItem(icon: Icon(Icons.group), label: "Community"),
      //   //   BottomNavigationBarItem(icon: Icon(Icons.apartment), label: "Organizations"),
      //   //   BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      //   // ],
      // ),
    );
  }
}