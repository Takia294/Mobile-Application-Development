import 'package:flutter/material.dart';

import '../screens/splash.dart';
import '../screens/login.dart';
import '../screens/registration.dart';
import '../screens/dashboard.dart';
import '../screens/emergency_request.dart';
import '../screens/myprofile.dart';
import '../screens/my_request.dart';
import '../screens/notification.dart';
import '../screens/find_donor.dart';
import '../screens/admin_dashboard.dart';

class AppRoutes {
  // ── Route constants ──
  static const String splash          = '/';
  static const String login           = '/login';
  static const String registration    = '/registration';
  static const String dashboard       = '/dashboard';
  static const String emergencyRequest = '/emergency-request';
  static const String myProfile       = '/my-profile';
  static const String myRequest       = '/my-request';
  static const String notification    = '/notification';
  static const String findDonor       = '/find-donor';
  static const String adminDashboard  = '/admin-dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _route(const SplashScreen());
      case login:
        return _route(const LoginScreen());
      case registration:
        return _route(const RegistrationScreen());
      case dashboard:
        return _route(const DashboardScreen());
      case emergencyRequest:
        return _route(const EmergencyRequestScreen());
      case myProfile:
        return _route(const MyProfileScreen());
      case myRequest:
        return _route(const MyRequestScreen());
      case notification:
        return _route(const NotificationScreen());
      case findDonor:
        return _route(const FindDonorScreen());
      case adminDashboard:
        return _route(const AdminDashboardScreen());
      default:
        return _route(_errorPage(settings.name));
    }
  }

  static MaterialPageRoute _route(Widget page) =>
      MaterialPageRoute(builder: (_) => page);

  static Widget _errorPage(String? name) => Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(
          child: Text('No route for: $name',
              style: const TextStyle(fontSize: 16)),
        ),
      );
}