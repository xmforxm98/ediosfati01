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

    if (user != null) {
      return const MainScreen();
    } else {
      return const InitialScreen();
    }
  }
}
