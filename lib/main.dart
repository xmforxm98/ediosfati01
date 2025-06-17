import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the generated file
import 'package:provider/provider.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/widgets/auth_wrapper.dart';
import 'services/notification_service.dart';
import 'services/image_service.dart';
import 'widgets/mobile_web_wrapper.dart';
import 'package:innerfive/constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use the generated options to initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification service
  await NotificationService().init();

  // 이미지 프리로딩 (백그라운드에서 실행)
  ImageService.preloadLoginBackgrounds().catchError((e) {
    debugPrint('Image preloading failed: $e');
  });

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
        title: 'Eidos Fati',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MobileWebWrapper(child: AuthWrapper()),
      ),
    );
  }
}
