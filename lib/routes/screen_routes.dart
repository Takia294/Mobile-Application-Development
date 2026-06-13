import 'package:flutter/material.dart';

/// USER SCREENS
import '../screens/splash.dart';
import '../screens/login.dart';
import '../screens/registration.dart';
import '../screens/dashboard.dart';
import '../screens/emergency_request.dart';
import '../screens/myprofile.dart';
import '../screens/my_request.dart';
import '../screens/notification.dart';
import '../screens/find_donor.dart';

/// ADMIN SCREEN
import '../screens/admin_dashboard.dart';

class AppRoutes {
  /// USER ROUTES
  static const String splash = '/';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String dashboard = '/dashboard';
  static const String emergencyRequest = '/emergency-request';
  static const String myProfile = '/my-profile';
  static const String myRequest = '/my-request';
  static const String notification = '/notification';
  static const String findDonor = '/find-donor';

  /// ADMIN ROUTE
  static const String adminDashboard = '/admin-dashboard';

  static Route<dynamic> generateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case registration:
        return MaterialPageRoute(
          builder: (_) => const RegistrationScreen(),
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );

      case emergencyRequest:
        return MaterialPageRoute(
          builder: (_) => const EmergencyRequestScreen(),
        );

      case myProfile:
        return MaterialPageRoute(
          builder: (_) => const MyProfileScreen(),
        );

      case myRequest:
        return MaterialPageRoute(
          builder: (_) => const MyRequestScreen(),
        );

      case notification:
        return MaterialPageRoute(
          builder: (_) => const NotificationScreen(),
        );

      case findDonor:
        return MaterialPageRoute(
          builder: (_) => const FindDonorScreen(),
        );

      /// ADMIN DASHBOARD
      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Route Error'),
            ),
            body: Center(
              child: Text(
                'No route found for ${settings.name}',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
    }
  }
}