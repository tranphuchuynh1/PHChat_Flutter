import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailAuthentication extends StatefulWidget {
  @override
  _EmailAuthenticationState createState() => _EmailAuthenticationState();
}

class _EmailAuthenticationState extends State<EmailAuthentication> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email = '';
  Timer? _timer;

  Future<void> _verifyEmail() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          // Fetch the user information from Firestore
          QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: _email)
              .where('isVerified', isEqualTo: false) // Ensure the user is not already verified
              .get();

          if (userQuerySnapshot.docs.isNotEmpty) {
            DocumentSnapshot userDoc = userQuerySnapshot.docs.first;

            // upload data Thông Tin Người Dùng on Firestore
            await FirebaseFirestore.instance.collection('Thông Tin Người Dùng').doc(user.uid).set({
              'username': userDoc['username'],
              'email': userDoc['email'],
              'password': userDoc['password'],
              'occupation': userDoc['occupation'],
              'isVerified': true,
              'profilePictureUrl' : '',
              'trạng thái' : '',
            });

            // Delete the unverified user data
            await FirebaseFirestore.instance.collection('users').doc(userDoc.id).delete();

            // Redirect to success page
            Navigator.pushNamed(context, '/successregister');
          }
        } else {
         // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please verify your email before proceeding.')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }


  @override
  void initState() {
    super.initState();
    // Get email from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _email = args['email'];
        });
        _startVerificationCheck();
      }
    });
  }
// time xác thực
  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _verifyEmail();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please verify your email.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyEmail,
              child: const Text('I have verified my email'),
            ),
          ],
        ),
      ),
    );
  }
}
