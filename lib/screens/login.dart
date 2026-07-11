import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes/screen_routes.dart';
import '../services/auth_service.dart';
import 'registration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// LOGIN USER (Admin & User)
  Future<void> loginUser() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      setState(() => isLoading = true);

      // ── Auth + role lookup, routed through AuthService so every
      // screen agrees on how a role is determined and validated ──
      final role = await AuthService.loginAndGetRole(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (role == 'admin') {
        _showMessage('Welcome Admin!', isSuccess: true);
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        _showMessage('Login Successful', isSuccess: true);
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } on AuthServiceException catch (e) {
      _showMessage(e.message);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later';
          break;
        case 'network-request-failed':
          message = 'No internet connection';
          break;
        default:
          message = e.message ?? 'Login Failed';
      }
      _showMessage(message);
    } catch (e) {
      _showMessage('Something went wrong');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// SHOW SNACKBAR
  void _showMessage(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        content: Text(message),
      ),
    );
  }

  /// FORGOT PASSWORD — sends a real Firebase password reset email.
  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: emailController.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter your account email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Send Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('Password reset link sent to $email', isSuccess: true);
    } on FirebaseAuthException catch (e) {
      _showMessage(e.code == 'user-not-found'
          ? 'No account found with this email'
          : (e.message ?? 'Could not send reset link'));
    } catch (_) {
      _showMessage('Could not send reset link');
    }
  }

  bool isSocialLoading = false;

  /// GOOGLE SIGN-IN
  Future<void> _loginWithGoogle() async {
    setState(() => isSocialLoading = true);
    try {
      final role = await AuthService.signInWithGoogle();
      if (!mounted) return;
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } on AuthServiceException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => isSocialLoading = false);
    }
  }

  /// APPLE SIGN-IN
  Future<void> _loginWithApple() async {
    setState(() => isSocialLoading = true);
    try {
      final role = await AuthService.signInWithApple();
      if (!mounted) return;
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } on AuthServiceException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Apple sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => isSocialLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// LOGO
                  Image.asset(
                    'assets/images/logo.png',
                    height: 90,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.favorite,
                        color: Color(0xFFE53935),
                        size: 80,
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  /// TITLE
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(text: 'Welcome '),
                        TextSpan(
                          text: 'Back!',
                          style: TextStyle(color: Color(0xFFE53935)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Login to continue your life-saving journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 35),

                  /// EMAIL FIELD
                  _buildInputField(
                    controller: emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Enter valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  /// PASSWORD FIELD
                  _buildInputField(
                    controller: passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Minimum 6 characters required';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => obscurePassword = !obscurePassword);
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFFE53935)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isLoading ? null : loginUser,
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// OR DIVIDER
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// GOOGLE LOGIN
                  _socialButton(
                    icon: Icons.g_mobiledata,
                    text: 'Continue with Google',
                    onTap: isSocialLoading ? null : _loginWithGoogle,
                  ),

                  const SizedBox(height: 15),

                  /// APPLE LOGIN
                  _socialButton(
                    icon: Icons.apple,
                    text: 'Continue with Apple',
                    onTap: isSocialLoading ? null : _loginWithApple,
                  ),

                  const SizedBox(height: 35),

                  /// SIGN UP ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegistrationScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// INPUT FIELD BUILDER
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  /// SOCIAL BUTTON BUILDER
  Widget _socialButton({
    required IconData icon,
    required String text,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSocialLoading)
              const SizedBox(
                height: 18, width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(icon, size: 26),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}