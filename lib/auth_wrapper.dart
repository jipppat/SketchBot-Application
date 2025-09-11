import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/homepage.dart';
import 'pages/login.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // 🔹 ต้องส่ง favorites และ onFavoriteToggle
          return HomePage(
            favorites: [],
            onFavoriteToggle: (url) {
              // ตอนนี้ยังไม่ต้องทำอะไร (คุณอาจจะเก็บลง Firestore ทีหลังได้)
              debugPrint("Favorite toggled: $url");
            },
          );
        }

        return const LoginPage();
      },
    );
  }
}
