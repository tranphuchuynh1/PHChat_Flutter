import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Notifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Kết Bạn')
            .where('to', isEqualTo: currentUser!.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No friend requests'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestDoc = requests[index];
              final requestData = requestDoc.data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.person_add),
                title: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Thông Tin Người Dùng')
                      .doc(requestData['from'])
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading...');
                    }
                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                    return Text(userData['username']);
                  },
                ),
                subtitle: const Text('sent you a friend request'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                        // Khi người dùng chấp nhận lời mời kết bạn
                        onPressed: () async {
                          final friendUid = requestData['from'];

                          // Cập nhật trạng thái yêu cầu kết bạn thành 'accepted'
                          await FirebaseFirestore.instance
                              .collection('Kết Bạn')
                              .doc(requestDoc.id)
                              .update({'status': 'accepted'});

                          // Lấy thông tin người dùng hiện tại
                          final currentUserData = (await FirebaseFirestore.instance
                              .collection('Thông Tin Người Dùng')
                              .doc(currentUser.uid)
                              .get())
                              .data() as Map<String, dynamic>;

                          // Lấy thông tin người bạn
                          final friendUserData = (await FirebaseFirestore.instance
                              .collection('Thông Tin Người Dùng')
                              .doc(friendUid)
                              .get())
                              .data() as Map<String, dynamic>;

                          // Thêm người bạn vào danh sách bạn bè của người dùng hiện tại
                          await FirebaseFirestore.instance
                              .collection('Friends')
                              .doc(currentUser.uid)
                              .collection('userFriends')
                              .doc(friendUid)
                              .set({
                            'username': friendUserData['username'],
                            'occupation': friendUserData['occupation'],
                            'profilePictureUrl': friendUserData['profilePictureUrl'],
                            'uid': friendUid, // Đảm bảo rằng uid được lưu trữ
                            // Các trường khác nếu cần... hehe
                          });

                          // Thêm người dùng hiện tại vào danh sách bạn bè của người bạn
                          await FirebaseFirestore.instance
                              .collection('Friends')
                              .doc(friendUid)
                              .collection('userFriends')
                              .doc(currentUser.uid)
                              .set({
                            'username': currentUserData['username'],
                            'occupation': currentUserData['occupation'],
                            'profilePictureUrl': currentUserData['profilePictureUrl'],
                            'uid': currentUser.uid, // Đảm bảo rằng uid được lưu trữ
                            // Các trường khác nếu cần...
                          });
                        }
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('Kết Bạn')
                            .doc(requestDoc.id)
                            .update({'status': 'rejected'});
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
