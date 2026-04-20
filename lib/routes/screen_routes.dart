import 'package:flutter/material.dart';

// Import all screens
import '../screens/splash.dart';
import '../screens/login.dart';
import '../screens/registration.dart';
//import '../screens/dashboard.dart';
//import '../screens/find_donor.dart';
//import '../screens/emergency_request.dart';
//import '../screens/my_request.dart';
//import '../screens/my_profile.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String dashboard = '/dashboard';
  static const String findDonor = '/find-donor';
  static const String emergencyRequest = '/emergency-request';
  static const String myRequest = '/my-request';
  static const String myProfile = '/my-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case registration:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());

      /*case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case findDonor:
        return MaterialPageRoute(builder: (_) => const FindDonorScreen());

      case emergencyRequest:
        return MaterialPageRoute(builder: (_) => const EmergencyRequestScreen());

      case myRequest:
        return MaterialPageRoute(builder: (_) => const MyRequestScreen());

      case myProfile:
        return MaterialPageRoute(builder: (_) => const MyProfileScreen());*/

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No route found')),
          ),
        );
    }
  }
}