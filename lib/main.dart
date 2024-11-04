import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'Authenticate/Email_Authentication.dart';
import 'Authenticate/Successfully_Register.dart';
import 'Authenticate/Login.dart';
import 'Authenticate/Register.dart';
import 'Screen/ChatRoomScreen.dart';
import 'Screen/HomeScreen.dart';
import 'Screen/ProfileScreen.dart';
import 'SplashView/FirstForm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDJ9Sc8vZYx6JAS9b0Xar_2e3rYqYUsWoA",
        authDomain: "phchat-flutter-6fa35.firebaseapp.com",
        projectId: "phchat-flutter-6fa35",
        storageBucket: "phchat-flutter-6fa35.appspot.com",
        messagingSenderId: "789599441495",
        appId: "1:789599441495:web:ed95bc038fff9a658fc912",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirstForm(),
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => Register(),
        '/email_auth': (context) => EmailAuthentication(),
        '/successregister': (context) => const SuccessfullyRegister(),
        '/homescreen': (context) => const HomeScreen(),
        '/profilescreen': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chatroomscreen') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return ChatRoomScreen(
                chatRoomId: args['chatRoomId'],
                userMap: args['userMap'],
              );
            },
          );
        }
        return null;
      },
    );
  }
}
