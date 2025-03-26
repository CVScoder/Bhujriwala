import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bujriwala/screens/sign_in_screen.dart'; // Updated path
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(BujriwalaApp());
}

class BujriwalaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bujriwala',
      theme: ThemeData(primarySwatch: Colors.green),
      home: SignInScreen(),
    );
  }
}