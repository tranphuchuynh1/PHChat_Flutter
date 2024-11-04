import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Future<void> sendFriendRequest() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('Kết Bạn').add({
      'from': currentUser!.uid,
      'to': widget.userId,
      'status': 'pending',
    });
    // Hiển thị snackbar hoặc thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Thông Tin Người Dùng')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final username = userData['username'] ?? 'Chưa cập nhật';
          final occupation = userData['occupation'] ?? 'Chưa cập nhật';
          final profilePictureUrl = userData['profilePictureUrl'] ??
              'assets/images/anh-dai-dien.png';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePictureUrl != 'assets/images/anh-dai-dien.png'
                        ? NetworkImage(profilePictureUrl)
                        : AssetImage(profilePictureUrl) as ImageProvider,
                  ),
                  const SizedBox(height: 20),
                  Text(username, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(occupation, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: sendFriendRequest,
                    child: const Text('Gửi kết bạn'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
