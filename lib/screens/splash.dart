import 'package:flutter/material.dart';
import '../routes/screen_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        children: [

          /// ❤️ Background floating hearts (light)
          Positioned(
            bottom: 20,
            left: 10,
            child: Icon(Icons.favorite, color: Colors.red.withOpacity(0.15), size: 20),
          ),
          Positioned(
            bottom: 60,
            right: 20,
            child: Icon(Icons.favorite, color: Colors.red.withOpacity(0.15), size: 18),
          ),
          Positioned(
            bottom: 120,
            left: 40,
            child: Icon(Icons.favorite, color: Colors.red.withOpacity(0.1), size: 16),
          ),

          /// ❤️ Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// LOGO (use your image)
                Image.asset(
                  'lib/screens/logo.png', // 👈 IMPORTANT
                  width: 120,
                ),

                const SizedBox(height: 20),

                /// APP NAME
                const Text(
                  'LifeLink',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
                  ),
                ),

                const SizedBox(height: 8),

                /// TAGLINE
                const Text(
                  'Connecting Lives, Saving Lives',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 40),

                /// DOT INDICATOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(false),
                    _dot(true),   // active dot
                    _dot(false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dot widget
  Widget _dot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.red : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}