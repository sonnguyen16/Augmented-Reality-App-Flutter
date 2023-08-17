import 'screen/welcome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screen/navigation.dart';




// ignore: must_be_immutable
class App extends StatelessWidget {
  const App({super.key});
  // Check if user is logged in
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
      home: user != null ? const HomeScreen() : const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
