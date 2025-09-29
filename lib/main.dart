import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/widgets/auth_wrapper.dart';
import 'package:innerfive/widgets/web_layout_wrapper.dart';
import 'package:innerfive/constants/app_theme.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:innerfive/services/notification_service.dart';
import 'package:innerfive/services/language_service.dart';
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

  // Initialize notification service only on mobile platforms
  if (!kIsWeb) {
    await NotificationService().init();
    await NotificationService().setDailyBriefingEnabled(true);
  }

  // Initialize language service
  final languageService = LanguageService();
  await languageService.initializeLanguage();

  runApp(MyApp(languageService: languageService));
}

class MyApp extends StatelessWidget {
  final LanguageService languageService;

  const MyApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<LanguageService>.value(value: languageService),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().user,
          initialData: null,
        ),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'Eidos Fati - Inner Five',
            theme: AppTheme.darkTheme,
            home: const WebLayoutWrapper(child: AuthWrapper()),
            debugShowCheckedModeBanner: false,

            // 다국어 지원 설정
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageService.supportedLocales,
            locale: languageService.currentLocale,

            // 로케일 해결 콜백
            localeResolutionCallback: (locale, supportedLocales) {
              // 사용자가 수동으로 언어를 설정한 경우
              if (languageService.currentLocale != null) {
                return languageService.currentLocale;
              }

              // 시스템 언어가 지원되는지 확인
              if (locale != null) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }
              }

              // 기본값으로 영어 반환
              return const Locale('en', '');
            },
          );
        },
      ),
    );
  }
}
