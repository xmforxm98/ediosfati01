import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/widgets/auth_wrapper.dart';
import 'package:innerfive/constants/app_theme.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:innerfive/utils/tag_image_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load tag image URLs at startup
  await TagImageManager.loadTagImageUrls();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Inner Five',
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
