import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SketchBot',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const AuthWrapper(), // ✅ ใช้ AuthWrapper เป็นตัวคุม flow
      debugShowCheckedModeBanner: false,
    );
  }
}
