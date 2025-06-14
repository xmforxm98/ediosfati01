import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the generated file
import 'package:provider/provider.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/initial_screen.dart';
import 'package:innerfive/screens/main_screen.dart';
import 'services/notification_service.dart';
import 'services/image_service.dart';
import 'widgets/mobile_web_wrapper.dart';

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
        Provider<AuthService>(create: (_) => AuthService()),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Eidos Fati',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF1a1a1a),
          scaffoldBackgroundColor: const Color(0xFF1a1a1a),
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Colors.blueAccent,
            surface: Color(0xFF2c2c2c),
          ),
          fontFamily: 'Roboto',
        ),
        home: const MobileWebWrapper(child: AuthWrapper()),
      ),
    );
  }
}

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

/*
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
*/
