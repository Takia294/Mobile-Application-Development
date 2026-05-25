import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes/screen_routes.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    super.key,
  });

  @override
  State<RegistrationScreen>
      createState() =>
          _RegistrationScreenState();
}

class _RegistrationScreenState
    extends State<
        RegistrationScreen> {

  final _formKey =
      GlobalKey<FormState>();

  /// CONTROLLERS
  final fullNameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final houseController =
      TextEditingController();

  final roadController =
      TextEditingController();

  final areaController =
      TextEditingController();

  final cityController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  /// VARIABLES
  DateTime? selectedDate;

  String? gender;

  bool obscurePassword = true;

  bool obscureConfirmPassword =
      true;

  bool isLoading = false;

  /// DATE PICKER
  Future<void> pickDate() async {

    DateTime? picked =
        await showDatePicker(

      context: context,

      initialDate:
          DateTime(2000),

      firstDate:
          DateTime(1950),
      lastDate:
          DateTime.now(),
    );

    if (picked != null) {

      setState(() {

        selectedDate = picked;
      });
    }
  }

  /// FIREBASE REGISTER
  Future<void> registerUser() async {
    try {
      setState(() {
        isLoading = true;
      });

      /// CREATE USER
      UserCredential userCredential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email:
            emailController.text.trim(),
        password:
            passwordController.text.trim(),
      );

      /// USER ID
      String uid =
          userCredential.user!.uid;

      /// SAVE USER DATA TO FIRESTORE
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        "uid": uid,
        "fullName":
            fullNameController.text
                .trim(),
        "email":
            emailController.text.trim(),
        "phone":
            phoneController.text.trim(),
        "house":
            houseController.text.trim(),
        "road":
            roadController.text.trim(),
        "area":
            areaController.text.trim(),
        "city":
            cityController.text.trim(),
        "gender":
            gender ?? "Not Set",
        "dob":
            selectedDate != null
                ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                : "",
        "bloodGroup": "None",
        "donorType": "None",
        "createdAt":
            Timestamp.now(),
      });

      if (!mounted) return;

      _showSnackBar(
        "Registration Successful",
      );

      /// GO TO LOGIN
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.login,
      );
    } on FirebaseAuthException catch (e) {
      String message =
          "Registration Failed";

      if (e.code ==
          'email-already-in-use') {
        message =
            "Email already exists";
      } else if (e.code ==
          'weak-password') {
        message =
            "Password is too weak";
      } else if (e.code ==
          'invalid-email') {
        message =
            "Invalid email";
      }

      _showSnackBar(message);
    } catch (e) {
      _showSnackBar(
        e.toString(),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {

    fullNameController.dispose();

    emailController.dispose();

    phoneController.dispose();

    houseController.dispose();

    roadController.dispose();

    areaController.dispose();

    cityController.dispose();

    passwordController.dispose();

    confirmPasswordController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF6F6F6,
      ),

      appBar: AppBar(
        title: const Text(
          "Create Account",
        ),

        backgroundColor:
            const Color(
          0xFFE53935,
        ),
      ),

      body:
          SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          24,
        ),

        child: Form(

          key: _formKey,

          child: Column(
            children: [

              /// FULL NAME
              _inputField(
                controller:
                    fullNameController,

                label:
                    "Full Name",

                icon:
                    Icons.person,

                requiredField:
                    true,
              ),

              const SizedBox(
                  height: 15),

              /// EMAIL
              _inputField(
                controller:
                    emailController,

                label: "Email",

                icon:
                    Icons.email,

                requiredField:
                    true,
                isEmail: true,
              ),

              const SizedBox(
                  height: 15),

              /// DATE OF BIRTH
              GestureDetector(

                onTap: pickDate,

                child: Container(

                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),

                  decoration:
                      BoxDecoration(

                    color:
                        Colors.white,

                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.cake,
                      ),

                      const SizedBox(
                          width: 10),

                      Text(

                        selectedDate ==
                                null
                            ? "Select Date of Birth"
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                  height: 15),

              /// GENDER
              Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  const Align(
                    alignment:
                        Alignment
                            .centerLeft,

                    child: Text(
                      "Gender",

                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),

                  Row(
                    children: [

                      Radio(
                        value:
                            "Male",

                        groupValue:
                            gender,

                        onChanged:
                            (value) {
                          setState(() {
                            gender =
                                value;
                          });
                        },
                      ),

                      const Text(
                        "Male",
                      ),

                      Radio(
                        value:
                            "Female",

                        groupValue:
                            gender,

                        onChanged:
                            (value) {
                          setState(() {
                            gender =
                                value;
                          });
                        },
                      ),

                      const Text(
                        "Female",
                      ),

                      Radio(
                        value:
                            "Other",

                        groupValue:
                            gender,

                        onChanged:
                            (value) {
                          setState(() {
                            gender =
                                value;
                          });
                        },
                      ),

                      const Text(
                        "Other",
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(
                  height: 15),

              /// PHONE
              _inputField(

                controller:
                    phoneController,

                label:
                    "Phone Number",

                icon:
                    Icons.phone,

                requiredField:
                    true,
              ),

              const SizedBox(
                  height: 20),

              /// ADDRESS TITLE
              const Align(

                alignment:
                    Alignment
                        .centerLeft,

                child: Text(

                  "Address (Optional)",

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(
                  height: 10),

              _inputField(
                controller:
                    houseController,
                label: "House",
                icon: Icons.home,
              ),

              const SizedBox(
                  height: 10),

              _inputField(
                controller:
                    roadController,
                label: "Road",
                icon: Icons.route,
              ),

              const SizedBox(
                  height: 10),

              _inputField(
                controller:
                    areaController,
                label: "Area",
                icon: Icons
                    .location_city,
              ),

              const SizedBox(
                  height: 10),

              _inputField(
                controller:
                    cityController,
                label: "City",
                icon: Icons
                    .location_on,
              ),

              const SizedBox(
                  height: 20),

              /// PASSWORD
              _passwordField(

                controller:
                    passwordController,

                label:
                    "Create Password",

                obscure:
                    obscurePassword,

                toggle: () {

                  setState(() {

                    obscurePassword =
                        !obscurePassword;
                  });
                },
              ),

              const SizedBox(
                  height: 15),

              /// CONFIRM PASSWORD
              _passwordField(

                controller:
                    confirmPasswordController,

                label:
                    "Confirm Password",

                obscure:
                    obscureConfirmPassword,

                toggle: () {

                  setState(() {

                    obscureConfirmPassword =
                        !obscureConfirmPassword;
                  });
                },
              ),

              const SizedBox(
                  height: 30),

              /// REGISTER BUTTON
              SizedBox(

                width:
                    double.infinity,

                height: 50,

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
                      isLoading
                          ? null
                          : () async {
                              if (!_formKey
                                  .currentState!
                                  .validate()) {
                                return;
                              }

                              if (selectedDate ==
                                  null) {
                                _showSnackBar(
                                  "Please select date of birth",
                                );
                                return;
                              }

                              if (gender ==
                                  null) {
                                _showSnackBar(
                                  "Please select gender",
                                );
                                return;
                              }

                              if (passwordController
                                      .text !=
                                  confirmPasswordController
                                      .text) {
                                _showSnackBar(
                                  "Passwords do not match",
                                );
                                return;
                              }

                              await registerUser();
                            },

                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                              color:
                                  Colors.white,
                            )
                          : const Text(
                              "Create Account",

                              style:
                                  TextStyle(
                                fontSize:
                                    16,

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
                  height: 20),

              /// LOGIN
              Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [

                  const Text(
                    "Already have an account? ",
                  ),

                  GestureDetector(

                    onTap: () {

                      Navigator.pop(
                        context,
                      );
                    },

                    child:
                        const Text(

                      "Login",

                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFFE53935,
                        ),

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// SNACKBAR
  void _showSnackBar(
      String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(message),
      ),
    );
  }

  /// INPUT FIELD
  Widget _inputField({

    required TextEditingController
        controller,

    required String label,

    required IconData icon,

    bool requiredField =
        false,

    bool isEmail = false,
  }) {

    return TextFormField(

      controller: controller,

      decoration:
          InputDecoration(

        labelText: label,

        prefixIcon:
            Icon(icon),

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

      validator: (value) {

        if (requiredField &&
            (value == null ||
                value
                    .trim()
                    .isEmpty)) {

          return "$label is required";
        }

        if (isEmail &&
            value != null &&
            !value.contains('@')) {
          return "Enter valid email";
        }

        return null;
      },
    );
  }

  /// PASSWORD FIELD
  Widget _passwordField({

    required TextEditingController
        controller,

    required String label,

    required bool obscure,

    required VoidCallback
        toggle,

  }) {

    return TextFormField(

      controller: controller,

      obscureText: obscure,

      decoration:
          InputDecoration(

        labelText: label,

        prefixIcon:
            const Icon(
          Icons.lock,
        ),

        suffixIcon:
            IconButton(

          icon: Icon(

            obscure
                ? Icons
                    .visibility_off
                : Icons
                    .visibility,
          ),

          onPressed: toggle,
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

      validator: (value) {

        if (value == null ||
            value.isEmpty) {

          return "$label required";
        }

        if (value.length < 6) {

          return "Password must be at least 6 characters";
        }

        return null;
      },
    );
  }
}