import 'package:flutter/material.dart';
import 'registration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool obscurePassword = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: Stack(
        children: [

          /// HEART BACKGROUND
          Positioned(
            bottom: 30,
            left: 10,
            child: Icon(Icons.favorite,
                color: Colors.red.withOpacity(0.15), size: 24),
          ),

          Positioned(
            bottom: 80,
            right: 20,
            child: Icon(Icons.favorite,
                color: Colors.red.withOpacity(0.12), size: 18),
          ),

          Positioned(
            bottom: 10,
            right: 80,
            child: Icon(Icons.favorite,
                color: Colors.red.withOpacity(0.10), size: 16),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  const SizedBox(height: 40),

                  /// LOGO
                  Image.asset(
                    'lib/screens/logo.png',
                    height: 80,
                  ),

                  const SizedBox(height: 30),

                  /// Welcome Text
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(text: "Welcome "),
                        TextSpan(
                          text: "Back!",
                          style: TextStyle(color: Color(0xFFE53935)),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Login to continue your life-saving journey",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Email / Phone
                  _inputField(
                    controller: emailController,
                    hint: "Email or Phone Number",
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 15),

                  /// Enter Email
                  _inputField(
                    controller: emailController,
                    hint: "Enter your email or phone",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 15),

                  /// Password
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,

                    decoration: InputDecoration(
                      hintText: "Password",

                      prefixIcon: const Icon(Icons.lock_outline),

                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Color(0xFFE53935)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// LOGIN BUTTON
                  SizedBox(
                    height: 52,
                    width: double.infinity,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: () {},

                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// OR Divider
                  Row(
                    children: const [

                      Expanded(child: Divider()),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("OR"),
                      ),

                      Expanded(child: Divider()),

                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Google Button
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Google Login Coming Soon"),
                        ),
                      );
                    },
                    child: _socialButton(
                      icon: Icons.g_mobiledata,
                      text: "Continue with Google",
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// Apple Button
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Apple Login Coming Soon"),
                        ),
                      );
                    },
                    child: _socialButton(
                      icon: Icons.apple,
                      text: "Continue with Apple",
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Sign Up Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text(
                        "Don’t have an account? ",
                        style: TextStyle(color: Colors.black54),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegistrationScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )

                    ],
                  ),

                  const SizedBox(height: 40),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// INPUT FIELD
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(icon),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// SOCIAL BUTTON UI
  Widget _socialButton({
    required IconData icon,
    required String text,
  }) {
    return Container(
      height: 50,
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(icon, size: 24),

          const SizedBox(width: 10),

          Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),

        ],
      ),
    );
  }
}