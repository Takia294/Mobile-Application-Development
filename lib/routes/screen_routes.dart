import 'package:flutter/material.dart';

/// IMPORT ALL SCREENS
import '../screens/splash.dart';
import '../screens/login.dart';
import '../screens/registration.dart';
import '../screens/dashboard.dart';
import '../screens/emergency_request.dart';
import '../screens/myprofile.dart';
import '../screens/my_request.dart';
import '../screens/notification.dart';
import '../screens/find_donor.dart'; // NEW

class AppRoutes {
  /// ROUTE NAMES
  static const String splash = '/';

  static const String login =
      '/login';

  static const String registration =
      '/registration';

  static const String dashboard =
      '/dashboard';

  static const String emergencyRequest =
      '/emergency-request';

  static const String myProfile =
      '/my-profile';

  static const String myRequest =
      '/my-request';

  static const String notification =
      '/notification';

  static const String findDonor =
      '/find-donor'; // NEW

  /// GENERATE ROUTE
  static Route<dynamic> generateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {

      /// SPLASH
      case splash:
        return MaterialPageRoute(
          builder: (_) =>
              const SplashScreen(),
        );

      /// LOGIN
      case login:
        return MaterialPageRoute(
          builder: (_) =>
              const LoginScreen(),
        );

      /// REGISTRATION
      case registration:
        return MaterialPageRoute(
          builder: (_) =>
              const RegistrationScreen(),
        );

      /// DASHBOARD
      case dashboard:
        return MaterialPageRoute(
          builder: (_) =>
              const DashboardScreen(),
        );

      /// EMERGENCY REQUEST
      case emergencyRequest:
        return MaterialPageRoute(
          builder: (_) =>
              const EmergencyRequestScreen(),
        );

      /// FIND DONOR
      case findDonor:
        return MaterialPageRoute(
          builder: (_) =>
              const FindDonorScreen(),
        );

      /// MY PROFILE
      case myProfile:
        return MaterialPageRoute(
          builder: (_) =>
              const MyProfileScreen(),
        );

      /// MY REQUEST
      case myRequest:
        return MaterialPageRoute(
          builder: (_) =>
              const MyRequestScreen(),
        );

      /// NOTIFICATION
      case notification:
        return MaterialPageRoute(
          builder: (_) =>
              const NotificationScreen(),
        );

      /// DEFAULT ERROR
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(
            body: Center(
              child: Text(
                'No route found',
              ),
            ),
          ),
        );
    }
  }
}