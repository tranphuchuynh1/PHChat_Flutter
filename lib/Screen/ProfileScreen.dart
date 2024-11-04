import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

import 'HomeScreen.dart'; // Import HomeScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _usernameController = TextEditingController();
  final _occupationController = TextEditingController();

  Future<void> _pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image;

    if (kIsWeb) {
      // Pick image for web
      image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Upload image for web
        await _uploadImageWeb(image);
      }
    } else {
      // Pick image for mobile
      image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File file = File(image.path);
        await _uploadImageMobile(file);
      }
    }
  }

  Future<void> _uploadImageWeb(XFile image) async {
    try {
      String fileName = basename(image.name);
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(_auth.currentUser!.uid)
          .child(fileName)
          .putData(await image.readAsBytes());

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Debug print
      print('Download URL (Web): $downloadUrl');

      // Update Firestore with new profile picture URL
      await _firestore
          .collection('Thông Tin Người Dùng')
          .doc(_auth.currentUser!.uid)
          .update({'profilePictureUrl': downloadUrl});

      // Ensure the updated URL is shown in the UI
      setState(() {
        // Refresh UI with new profile picture URL
      });
    } catch (e) {
      // Handle errors
      print(e);
    }
  }

  Future<void> _uploadImageMobile(File file) async {
    try {
      String fileName = basename(file.path);
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('Ảnh Đại Diện Người Dùng')
          .child(_auth.currentUser!.uid)
          .child(fileName)
          .putFile(file);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Debug print
      print('Download URL (Mobile): $downloadUrl');

      // Update Firestore with new profile picture URL
      await _firestore
          .collection('Thông Tin Người Dùng')
          .doc(_auth.currentUser!.uid)
          .update({'profilePictureUrl': downloadUrl});

      // Ensure the updated URL is shown in the UI
      setState(() {
        // Refresh UI with new profile picture URL
      });
    } catch (e) {
      // Handle errors
      print(e);
    }
  }

  Future<void> _updateUserInfo() async {
    await _firestore.collection('Thông Tin Người Dùng').doc(_auth.currentUser!.uid).update({
      'username': _usernameController.text,
      'occupation': _occupationController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.pink],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('Thông Tin Người Dùng').doc(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};

                    _usernameController.text = userData['username'] ?? '';
                    _occupationController.text = userData['occupation'] ?? '';

                    return Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: userData['profilePictureUrl'] != null && userData['profilePictureUrl'].isNotEmpty
                                  ? NetworkImage(userData['profilePictureUrl'])
                                  : const AssetImage('assets/images/anh-dai-dien.png') as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickAndUploadImage,
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData['username'] ?? 'Username',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userData['occupation'] ?? 'Occupation',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _occupationController,
                          decoration: const InputDecoration(
                            labelText: 'Occupation',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _updateUserInfo,
                          child: const Text('Update Profile'),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Các tùy chọn khác
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Likes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.green),
                title: const Text('Pictures'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Colors.purple),
                title: const Text('Groups'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.orange),
                title: const Text('My Wallet'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.blue),
                title: const Text('Thông Tin Cá Nhân'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
