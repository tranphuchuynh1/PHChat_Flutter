import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phchat_huynhsenpai_flutter/Screen/Notifications.dart';
import 'package:phchat_huynhsenpai_flutter/Screen/SearchResults.dart';
import 'package:phchat_huynhsenpai_flutter/group_chats/group_chat_screen.dart';
import 'package:phchat_huynhsenpai_flutter/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      // Update the user's status to "Online" upon login
      FirebaseFirestore.instance
          .collection('Thông Tin Người Dùng')
          .doc(user.uid)
          .update({'trạng thái': 'Online'});
    }

    return Scaffold(
      backgroundColor: blueColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupChatHomeScreen(),
            ),
          );
        },
        backgroundColor: greenColor,
        child: const Icon(Icons.add, size: 20),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/logos/chatting.png'),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          height: 40,
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: (query) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchResults(searchQuery: query),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications, color: whiteColor),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Notifications()),
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: whiteColor),
                        onSelected: (value) {
                          if (value == 'Profile') {
                            Navigator.pushReplacementNamed(context, '/profilescreen');
                          } else if (value == 'Logout') {
                            // Update the user's status to "Offline" before logging out
                            FirebaseFirestore.instance
                                .collection('Thông Tin Người Dùng')
                                .doc(user.uid)
                                .update({'trạng thái': 'Offline'}).then((_) {
                              FirebaseAuth.instance.signOut();
                              Navigator.pushReplacementNamed(context, '/login');
                            });
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Profile', 'Logout'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Thông Tin Người Dùng')
                      .doc(user.uid)
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
                    final profilePictureUrl = userData['profilePictureUrl'] ?? 'assets/images/anh-dai-dien.png';

                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profilePictureUrl != 'assets/images/anh-dai-dien.png'
                              ? NetworkImage(profilePictureUrl)
                              : AssetImage(profilePictureUrl),
                        ),
                        const SizedBox(height: 20),
                        Text(username, style: whiteTextStyle.copyWith(fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(occupation, style: lightBlueTextStyle.copyWith(fontSize: 12)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(30),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bạn bè', style: titleTextStyle),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Friends')
                            .doc(user.uid)
                            .collection('userFriends')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No friends found'));
                          }

                          final friends = snapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: friends.length,
                            itemBuilder: (context, index) {
                              final friendData = friends[index].data() as Map<String, dynamic>;

                              return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: friendData['profilePictureUrl'] != 'assets/images/anh-dai-dien.png'
                                        ? NetworkImage(friendData['profilePictureUrl'])
                                        : const AssetImage('assets/images/anh-dai-dien.png'),
                                  ),
                                  title: Text(friendData['username']),
                                  subtitle: Text(friendData['occupation']),
                                  onTap: () {
                                    final chatRoomId = getChatRoomId(
                                        user.uid, friends[index].id);
                                    Navigator.pushNamed(
                                      context,
                                      '/chatroomscreen',
                                      arguments: {
                                        'chatRoomId': chatRoomId,
                                        'userMap': {
                                          'uid': friendData['uid'] ?? 'default_uid',
                                          'name': friendData['username'],
                                          'profilePic': friendData['profilePictureUrl'],
                                          'trạng thái': friendData.containsKey('trạng thái') ? friendData['trạng thái'] : 'No trạng thái available',
                                        },
                                      },
                                    );
                                  }
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getChatRoomId(String a, String b) {
    return a.compareTo(b) > 0 ? '$b\_$a' : '$a\_$b';
  }
}
