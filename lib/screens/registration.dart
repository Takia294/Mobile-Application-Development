import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes/screen_routes.dart';
import '../services/location_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    super.key,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  /// CONTROLLERS
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final houseController = TextEditingController();
  final roadController = TextEditingController();
  final areaController = TextEditingController();
  final cityController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// VARIABLES
  DateTime? selectedDate;
  String? gender;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  bool shareLocation = true; // helps donors be found on the map later

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
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// DATE PICKER
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// REGISTER USER
  Future<void> registerUser() async {
    try {
      setState(() => isLoading = true);

      /// CREATE USER IN FIREBASE AUTH
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      /// USER ID
      String uid = userCredential.user!.uid;

      /// TRY TO GET GPS LOCATION (non-blocking — registration still
      /// succeeds even if the user denies permission or GPS is off).
      /// This is what lets the free map in Find Donors show this
      /// donor's pin once they later set a donor type in My Profile.
      double? latitude;
      double? longitude;
      if (shareLocation) {
        try {
          final pos = await LocationService.getCurrentPosition();
          latitude = pos.latitude;
          longitude = pos.longitude;
        } catch (_) {
          // Silently skip — user can share location later from My Profile.
        }
      }

      /// SAVE USER DATA IN FIRESTORE
      /// role: 'user' by default
      /// donorType uses the canonical value 'None' — the same value
      /// FindDonorScreen/DonorService checks against, so filters stay
      /// consistent app-wide.
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "uid": uid,
        "fullName": fullNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "house": houseController.text.trim(),
        "road": roadController.text.trim(),
        "area": areaController.text.trim(),
        "city": cityController.text.trim(),
        "gender": gender ?? "",
        "dob": selectedDate != null
            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
            : "",
        "bloodGroup": "",
        "donorType": "None",
        "profileImage": "",
        "certificateImage": "",
        "role": "user", // ← login এ role check করার জন্য
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
        if (latitude != null) "locationUpdatedAt": Timestamp.now(),
        "createdAt": Timestamp.now(),
      });

      if (!mounted) return;

      _showSnackBar("Registration Successful");

      /// GO TO LOGIN
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } on FirebaseAuthException catch (e) {
      String message = "Registration Failed";

      switch (e.code) {
        case 'email-already-in-use':
          message = "Email already exists";
          break;
        case 'weak-password':
          message = "Password is too weak";
          break;
        case 'invalid-email':
          message = "Invalid email";
          break;
        case 'network-request-failed':
          message = "No internet connection";
          break;
        default:
          message = e.message ?? "Registration Failed";
      }

      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("Something went wrong");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: const Color(0xFFE53935),
          title: const Text(
            "Create Account",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  const Center(
                    child: Text(
                      "Register Your Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// FULL NAME
                  _inputField(
                    controller: fullNameController,
                    label: "Full Name",
                    icon: Icons.person,
                    requiredField: true,
                  ),

                  const SizedBox(height: 15),

                  /// EMAIL
                  _inputField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email,
                    requiredField: true,
                    isEmail: true,
                  ),

                  const SizedBox(height: 15),

                  /// PHONE
                  _inputField(
                    controller: phoneController,
                    label: "Phone Number",
                    icon: Icons.phone,
                    requiredField: true,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 15),

                  /// DATE OF BIRTH
                  GestureDetector(
                    onTap: pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cake, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedDate == null
                                  ? "Select Date of Birth"
                                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              style: TextStyle(
                                color: selectedDate == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// GENDER
                  const Text(
                    "Gender",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Male"),
                          value: "Male",
                          groupValue: gender,
                          onChanged: (value) => setState(() => gender = value),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Female"),
                          value: "Female",
                          groupValue: gender,
                          onChanged: (value) => setState(() => gender = value),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Other"),
                          value: "Other",
                          groupValue: gender,
                          onChanged: (value) => setState(() => gender = value),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ADDRESS
                  const Text(
                    "Address (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _inputField(
                    controller: houseController,
                    label: "House",
                    icon: Icons.home,
                  ),

                  const SizedBox(height: 10),

                  _inputField(
                    controller: roadController,
                    label: "Road",
                    icon: Icons.route,
                  ),

                  const SizedBox(height: 10),

                  _inputField(
                    controller: areaController,
                    label: "Area",
                    icon: Icons.location_city,
                  ),

                  const SizedBox(height: 10),

                  _inputField(
                    controller: cityController,
                    label: "City",
                    icon: Icons.location_on,
                  ),

                  const SizedBox(height: 20),

                  /// PASSWORD
                  _passwordField(
                    controller: passwordController,
                    label: "Create Password",
                    obscure: obscurePassword,
                    toggle: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),

                  const SizedBox(height: 15),

                  /// CONFIRM PASSWORD
                  _passwordField(
                    controller: confirmPasswordController,
                    label: "Confirm Password",
                    obscure: obscureConfirmPassword,
                    toggle: () => setState(
                        () => obscureConfirmPassword = !obscureConfirmPassword),
                    isConfirmPassword: true,
                  ),

                  const SizedBox(height: 10),

                  /// SHARE LOCATION TOGGLE
                  /// Lets nearby patients find this user on the free
                  /// donor map later, once they set a donor type.
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Checkbox(
                          value: shareLocation,
                          activeColor: const Color(0xFFE53935),
                          onChanged: (v) =>
                              setState(() => shareLocation = v ?? true),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => shareLocation = !shareLocation),
                            child: const Text(
                              "Share my location so nearby patients can find me on the donor map",
                              style: TextStyle(fontSize: 12.5, color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();

                              if (!_formKey.currentState!.validate()) return;

                              if (selectedDate == null) {
                                _showSnackBar("Please select date of birth");
                                return;
                              }

                              if (gender == null) {
                                _showSnackBar("Please select gender");
                                return;
                              }

                              await registerUser();
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// LOGIN LINK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// SNACKBAR
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// INPUT FIELD
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool requiredField = false,
    bool isEmail = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
      ),
      validator: (value) {
        if (requiredField && (value == null || value.trim().isEmpty)) {
          return "$label is required";
        }

        if (isEmail && value != null && value.trim().isNotEmpty) {
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value.trim())) {
            return "Enter valid email";
          }
        }

        if (label == "Phone Number") {
          if (value != null && value.trim().length < 11) {
            return "Enter valid phone number";
          }
        }

        return null;
      },
    );
  }

  /// PASSWORD FIELD
  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    bool isConfirmPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "$label required";
        if (value.length < 6) return "Password must be at least 6 characters";
        if (isConfirmPassword && value != passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }
}