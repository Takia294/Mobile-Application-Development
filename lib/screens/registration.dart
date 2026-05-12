import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState
    extends State<RegistrationScreen> {
  final _formKey =
      GlobalKey<FormState>();

  /// Controllers
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

  /// Variables
  DateTime? selectedDate;
  String? gender;

  bool obscurePassword = true;
  bool obscureConfirmPassword =
      true;

  /// DATE PICKER
  Future<void> pickDate() async {
    DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate:
          DateTime(2000),
      firstDate:
          DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// SAVE USER DATA
  Future<void> saveUserData()
      async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      'fullName',
      fullNameController.text,
    );

    await prefs.setString(
      'email',
      emailController.text,
    );

    await prefs.setString(
      'phone',
      phoneController.text,
    );

    await prefs.setString(
      'house',
      houseController.text,
    );

    await prefs.setString(
      'road',
      roadController.text,
    );

    await prefs.setString(
      'area',
      areaController.text,
    );

    await prefs.setString(
      'city',
      cityController.text,
    );

    await prefs.setString(
      'gender',
      gender ?? 'Not Set',
    );

    await prefs.setString(
      'dob',
      selectedDate
              ?.toString() ??
          '',
    );

    /// Future Profile Fields
    await prefs.setString(
      'bloodGroup',
      'None',
    );

    await prefs.setString(
      'donorType',
      'None',
    );
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
          const Color(0xFFF6F6F6),

      appBar: AppBar(
        title:
            const Text("Create Account"),
        backgroundColor:
            const Color(0xFFE53935),
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
                24),

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
                                12),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                          Icons.cake),

                      const SizedBox(
                          width:
                              10),

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
                  const Text(
                    "Gender",
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight
                              .bold,
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
                          setState(
                              () {
                            gender =
                                value;
                          });
                        },
                      ),
                      const Text(
                          "Male"),

                      Radio(
                        value:
                            "Female",
                        groupValue:
                            gender,
                        onChanged:
                            (value) {
                          setState(
                              () {
                            gender =
                                value;
                          });
                        },
                      ),
                      const Text(
                          "Female"),

                      Radio(
                        value:
                            "Other",
                        groupValue:
                            gender,
                        onChanged:
                            (value) {
                          setState(
                              () {
                            gender =
                                value;
                          });
                        },
                      ),
                      const Text(
                          "Other"),
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

              /// ADDRESS
              const Align(
                alignment:
                    Alignment
                        .centerLeft,
                child: Text(
                  "Address (Optional)",
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight
                            .bold,
                    fontSize:
                        16,
                  ),
                ),
              ),

              const SizedBox(
                  height: 10),

              _inputField(
                controller:
                    houseController,
                label: "House",
                icon:
                    Icons.home,
              ),

              const SizedBox(
                  height: 10),

              _inputField(
                controller:
                    roadController,
                label: "Road",
                icon:
                    Icons.route,
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
                            0xFFE53935),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),
                  ),

                  onPressed:
                      () async {
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

                    await saveUserData();

                    _showSnackBar(
                      "Registration Successful",
                    );
                  },

                  child:
                      const Text(
                    "Create Account",
                    style:
                        TextStyle(
                      fontSize:
                          16,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                  height: 20),

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
                          context);
                    },
                    child:
                        const Text(
                      "Login",
                      style:
                          TextStyle(
                        color: Color(
                            0xFFE53935),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(
      String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
    bool requiredField =
        false,
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
              BorderRadius
                  .circular(12),
          borderSide:
              BorderSide.none,
        ),
      ),

      validator: (value) {
        if (requiredField &&
            (value == null ||
                value
                    .isEmpty)) {
          return "$label is required";
        }
        return null;
      },
    );
  }

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
              BorderRadius
                  .circular(12),
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