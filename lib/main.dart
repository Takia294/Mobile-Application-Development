import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'routes/screen_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint(
      'Firebase Initialized Successfully',
    );
  } catch (e) {
    debugPrint(
      'Firebase Initialization Error: $e',
    );
  }

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'LifeLink',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),

        scaffoldBackgroundColor:
            const Color(0xFFF6F6F6),

        fontFamily: 'Roboto',

        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(
              double.infinity,
              52,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),
        ),

        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                BorderSide.none,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                BorderSide.none,
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),

          errorBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                const BorderSide(
              color: Colors.red,
            ),
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),

      /// START SCREEN
      initialRoute:
          AppRoutes.splash,

      /// APP ROUTES
      onGenerateRoute:
          AppRoutes.generateRoute,
    );
  }
}