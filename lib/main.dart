import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:track_bus/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter framework error: ${details.exception}');
  };

  try {
    await Firebase.initializeApp();

    runApp(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: 'splash',
          routes: {
            'splash': (context) => const SplashScreenPage(),

            // Optional fallback route for debugging
            // 'splash': (context) => const DebugPlaceholder(),
          },
        ),
      ),
    );
  } catch (e, stack) {
    print('Error during app initialization: $e');
    print('Stack trace: $stack');
  }
}

/// Optional debug placeholder in case SplashScreenPage is broken
class DebugPlaceholder extends StatelessWidget {
  const DebugPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Debug Placeholder')),
    );
  }
}
