import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/AuthScreens/authScreen.dart';
import 'package:flutter_samples/AuthScreens/splashScreen.dart';
import 'package:flutter_samples/UserScreens/userMainScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String userId;
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((firebaseUser) {
      if (firebaseUser != null) {
        setState(() {
          userId = firebaseUser.uid;
          print("Logged in user id ==========> " + userId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _getLandingPage(),
      routes: <String, WidgetBuilder>{
        '/AuthScreen': (BuildContext context) => AuthScreen(),
        '/UserMainScreen': (BuildContext context) => UserMainScreen(),
      },
    );
  }

  Widget _getLandingPage() {
    if (userId != null) {
      return UserMainScreen();
    } else if (userId == null) {
      return AuthScreen();
    } else {
      return SplashScreen();
    }
  }
}
