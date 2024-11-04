import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'UserProfileScreen.dart';

class SearchResults extends StatelessWidget {
  final String searchQuery;

  SearchResults({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Results')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Thông Tin Người Dùng')
            .where('username', isEqualTo: searchQuery)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Khong tim thay nguoi dung nao!'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userData = userDoc.data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: userData['profilePictureUrl'] != null
                      ? NetworkImage(userData['profilePictureUrl'])
                      : const AssetImage('assets/images/anh-dai-dien.png') as ImageProvider,
                ),
                title: Text(userData['username']),
                subtitle: Text(userData['occupation']),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('Kết Bạn').add({
                      'from': currentUser!.uid,
                      'to': userDoc.id,
                      'status': 'pending'
                    });
                    // Hiển thị snackbar hoặc thông báo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Friend request sent')),
                    );
                  },
                  child: const Text('Kết Bạn'),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(userId: userDoc.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
