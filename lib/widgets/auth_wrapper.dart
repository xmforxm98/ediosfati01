import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/screens/main_screen.dart';
import 'package:innerfive/screens/auth/initial_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    print('🔐 AuthWrapper - User: ${user?.uid ?? 'null'}');

    if (user != null) {
      print('🔐 AuthWrapper - 로그인된 사용자, MainScreen으로 이동');
      return const MainScreen();
    } else {
      print('🔐 AuthWrapper - 로그인되지 않음, InitialScreen으로 이동');
      return const InitialScreen();
    }
  }
}
