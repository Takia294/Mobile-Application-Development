import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'routes/screen_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    /// FIREBASE INITIALIZE
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions
              .currentPlatform,
    );
  } catch (e) {
    debugPrint(
      'Firebase Init Error: $e',
    );
  }

  runApp(const MyApp());
}

class MyApp
    extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false,

      title: 'LifeLink',

      theme: ThemeData(
        primarySwatch:
            Colors.red,

        scaffoldBackgroundColor:
            const Color(
          0xFFF6F6F6,
        ),

        fontFamily:
            'Roboto',

        useMaterial3:
            true,
      ),

      /// START SCREEN
      initialRoute:
          AppRoutes.splash,

      /// ROUTES
      onGenerateRoute:
          AppRoutes
              .generateRoute,
    );
  }
}