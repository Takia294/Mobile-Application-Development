import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/screen_routes.dart';
import 'registration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  bool obscurePassword = true;

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  @override
  void dispose() {

    emailController.dispose();

    passwordController.dispose();

    super.dispose();
  }

  /// LOGIN FUNCTION
  Future<void> loginUser() async {

    String email =
        emailController.text.trim();

    String password =
        passwordController.text.trim();

    /// EMPTY CHECK
    if (email.isEmpty ||
        password.isEmpty) {

      _showMessage(
        'Please fill all fields',
      );

      return;
    }

    /// EMAIL FORMAT CHECK
    if (!email.contains('@') &&
        email.length < 11) {

      _showMessage(
        'Enter valid email or phone number',
      );

      return;
    }

    /// PASSWORD LENGTH
    if (password.length < 6) {

      _showMessage(
        'Password must be at least 6 characters',
      );

      return;
    }

    /// GET SAVED DATA
    final prefs =
        await SharedPreferences
            .getInstance();

    String savedEmail =
        prefs.getString(
              'user_email',
            ) ??
            '';

    String savedPassword =
        prefs.getString(
              'user_password',
            ) ??
            '';

    /// AUTH CHECK
    if (email == savedEmail &&
        password ==
            savedPassword) {

      /// SAVE LOGIN STATE
      await prefs.setBool(
        'is_logged_in',
        true,
      );

      /// SUCCESS
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,
          content: Text(
            'Login Successful',
          ),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.dashboard,
      );
    }

    else {

      _showMessage(
        'Invalid email or password',
      );
    }
  }

  /// SHOW MESSAGE
  void _showMessage(
      String msg) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F6F6),

      body: Stack(
        children: [

          /// HEART BACKGROUND
          Positioned(
            bottom: 30,
            left: 10,
            child: Icon(
              Icons.favorite,
              color: Colors.red
                  .withOpacity(0.15),
              size: 24,
            ),
          ),

          Positioned(
            bottom: 80,
            right: 20,
            child: Icon(
              Icons.favorite,
              color: Colors.red
                  .withOpacity(0.12),
              size: 18,
            ),
          ),

          Positioned(
            bottom: 10,
            right: 80,
            child: Icon(
              Icons.favorite,
              color: Colors.red
                  .withOpacity(0.10),
              size: 16,
            ),
          ),

          SafeArea(
            child:
                SingleChildScrollView(

              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 24,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .center,

                children: [

                  const SizedBox(
                      height: 40),

                  /// LOGO
                  Image.asset(
                    'lib/screens/logo.png',
                    height: 80,
                  ),

                  const SizedBox(
                      height: 30),

                  /// WELCOME
                  RichText(
                    text:
                        const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            Colors.black,
                      ),

                      children: [

                        TextSpan(
                          text:
                              "Welcome ",
                        ),

                        TextSpan(
                          text:
                              "Back!",
                          style:
                              TextStyle(
                            color: Color(
                              0xFFE53935,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  const Text(
                    "Login to continue your life-saving journey",

                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Colors.black54,
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  /// EMAIL
                  _inputField(
                    controller:
                        emailController,

                    hint:
                        "Email or Phone Number",

                    icon: Icons
                        .person_outline,
                  ),

                  const SizedBox(
                      height: 15),

                  /// PASSWORD
                  TextField(

                    controller:
                        passwordController,

                    obscureText:
                        obscurePassword,

                    decoration:
                        InputDecoration(

                      hintText:
                          "Password",

                      prefixIcon:
                          const Icon(
                        Icons
                            .lock_outline,
                      ),

                      suffixIcon:
                          IconButton(

                        icon: Icon(

                          obscurePassword
                              ? Icons
                                  .visibility_off_outlined
                              : Icons
                                  .visibility_outlined,
                        ),

                        onPressed: () {

                          setState(() {

                            obscurePassword =
                                !obscurePassword;
                          });
                        },
                      ),

                      filled: true,

                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),

                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  /// FORGOT PASSWORD
                  Align(
                    alignment:
                        Alignment
                            .centerRight,

                    child: TextButton(

                      onPressed: () {

                        _showMessage(
                          'Forgot Password Coming Soon',
                        );
                      },

                      child:
                          const Text(

                        "Forgot Password?",

                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFFE53935,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  /// LOGIN BUTTON
                  SizedBox(

                    height: 52,

                    width:
                        double.infinity,

                    child:
                        ElevatedButton(

                      style:
                          ElevatedButton
                              .styleFrom(

                        backgroundColor:
                            const Color(
                          0xFFE53935,
                        ),

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),

                      onPressed:
                          loginUser,

                      child:
                          const Text(

                        "Login",

                        style:
                            TextStyle(

                          fontSize: 16,

                          fontWeight:
                              FontWeight
                                  .bold,

                          color:
                              Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 25),

                  /// OR DIVIDER
                  Row(
                    children:
                        const [

                      Expanded(
                        child:
                            Divider(),
                      ),

                      Padding(
                        padding:
                            EdgeInsets.symmetric(
                          horizontal:
                              10,
                        ),

                        child:
                            Text(
                          "OR",
                        ),
                      ),

                      Expanded(
                        child:
                            Divider(),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 20),

                  /// GOOGLE BUTTON
                  GestureDetector(

                    onTap: () {

                      _showMessage(
                        'Google Login Coming Soon',
                      );
                    },

                    child:
                        _socialButton(

                      icon: Icons
                          .g_mobiledata,

                      text:
                          "Continue with Google",
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  /// APPLE BUTTON
                  GestureDetector(

                    onTap: () {

                      _showMessage(
                        'Apple Login Coming Soon',
                      );
                    },

                    child:
                        _socialButton(

                      icon:
                          Icons.apple,

                      text:
                          "Continue with Apple",
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  /// SIGN UP
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [

                      const Text(
                        "Don’t have an account? ",

                        style:
                            TextStyle(
                          color: Colors
                              .black54,
                        ),
                      ),

                      GestureDetector(

                        onTap: () {

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) =>
                                      const RegistrationScreen(),
                            ),
                          );
                        },

                        child:
                            const Text(

                          "Sign Up",

                          style:
                              TextStyle(

                            color:
                                Color(
                              0xFFE53935,
                            ),

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 40),
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

    required TextEditingController
        controller,

    required String hint,

    required IconData icon,

  }) {

    return TextField(

      controller: controller,

      decoration:
          InputDecoration(

        hintText: hint,

        prefixIcon:
            Icon(icon),

        filled: true,

        fillColor: Colors.white,

        border:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  /// SOCIAL BUTTON
  Widget _socialButton({

    required IconData icon,

    required String text,

  }) {

    return Container(

      height: 50,

      width: double.infinity,

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        border: Border.all(
          color:
              Colors.grey.shade300,
        ),
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment
                .center,

        children: [

          Icon(
            icon,
            size: 24,
          ),

          const SizedBox(
              width: 10),

          Text(
            text,

            style:
                const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}