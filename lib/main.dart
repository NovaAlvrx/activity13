import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // Import the new screen file

void main() {
  runApp(const SignupAdventureApp());
}

class SignupAdventureApp extends StatelessWidget {
  const SignupAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup Adventure ',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(), // This points to your imported screen
      debugShowCheckedModeBanner: false,
    );
  }
}
