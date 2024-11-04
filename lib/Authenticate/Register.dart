import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:phchat_huynhsenpai_flutter/theme.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedOccupation;
  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _otp = '';

  String generateOTP() {
    var rng = Random();
    return (rng.nextInt(9000) + 1000).toString(); // Generate a 4-digit OTP
  }

  Future<void> sendOTPEmail(String email, String otp) async {
    final Email mail = Email(
      body: 'Your OTP is $otp',
      subject: 'OTP Verification',
      recipients: [email],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(mail);
    } catch (e) {
      print("Error sending email: $e");
    }
  }

  Future<void> _register() async {
    print('Register button pressed');
    if (_password != _confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        _otp = generateOTP();
        await sendOTPEmail(_email, _otp);

        // In thông tin để kiểm tra
        print('Saving user data to Firestore:');
        print('Username: $_username');
        print('Email: $_email');
        print('Password: $_password');
        print('Occupation: $_selectedOccupation');
        print('OTP: $_otp');
        print('Is Verified: false');

        // Lưu thông tin vào collection 'users'
        await _firestore.collection('users').doc(user.uid).set({
          'username': _username,
          'email': _email,
          'password': _password,
          'occupation': _selectedOccupation,
          'otp': _otp, // Store OTP temporarily
          'isVerified': false, // Add isVerified field
        });

        // Điều hướng đến màn hình email xác thực
        Navigator.pushNamed(context, '/email_auth', arguments: {'email': _email});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello! Register to get started',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => _username = value,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => _email = value,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                onChanged: (value) => _password = value,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                onChanged: (value) => _confirmPassword = value,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Nghề nghiệp',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                value: _selectedOccupation,
                items: [
                  'Lập trình viên',
                  'Thiết kế đồ họa',
                  'Nhà phát triển nội dung',
                  'Doanh nhân',
                  'Công việc tự do',
                  'Khác',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOccupation = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    padding: const EdgeInsets.symmetric(horizontal: 160, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Register', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('Or Register with', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset('assets/logos/facebook.png'),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset('assets/logos/gmail.png'),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset('assets/logos/apple.png'),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Login Now',
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/login');
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
