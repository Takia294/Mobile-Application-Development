import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/screen_routes.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() =>
      _MyProfileScreenState();
}

class _MyProfileScreenState
    extends State<MyProfileScreen> {
  final ImagePicker picker =
      ImagePicker();

  File? profileImage;
  File? certificateImage;

  /// USER DATA
  String fullName = 'None';
  String email = 'None';
  String phone = 'None';

  String house = '';
  String road = '';
  String area = '';
  String city = '';

  String bloodGroup = 'None';
  String donorType = 'None';

  String gender = 'None';
  String dob = 'None';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  /// LOAD USER DATA
  Future<void> loadUserData() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    if (!mounted) return;

    final profilePath =
        prefs.getString(
      'profileImage',
    );

    final certificatePath =
        prefs.getString(
      'certificateImage',
    );

    setState(() {
      fullName =
          prefs.getString(
            'fullName',
          ) ??
          'None';

      email =
          prefs.getString(
            'email',
          ) ??
          'None';

      phone =
          prefs.getString(
            'phone',
          ) ??
          'None';

      house =
          prefs.getString(
            'house',
          ) ??
          '';

      road =
          prefs.getString(
            'road',
          ) ??
          '';

      area =
          prefs.getString(
            'area',
          ) ??
          '';

      city =
          prefs.getString(
            'city',
          ) ??
          '';

      bloodGroup =
          prefs.getString(
            'bloodGroup',
          ) ??
          'None';

      donorType =
          prefs.getString(
            'donorType',
          ) ??
          'None';

      gender =
          prefs.getString(
            'gender',
          ) ??
          'None';

      dob =
          prefs.getString(
            'dob',
          ) ??
          'None';

      if (profilePath != null) {
        profileImage =
            File(profilePath);
      }

      if (certificatePath !=
          null) {
        certificateImage =
            File(certificatePath);
      }
    });
  }

  /// SAVE PROFILE INFO
  Future<void>
      saveProfileData() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      'bloodGroup',
      bloodGroup,
    );

    await prefs.setString(
      'donorType',
      donorType,
    );
  }

  /// SAVE IMAGE LOCALLY
  Future<File> _saveImage(
    XFile image,
    String fileName,
  ) async {
    final directory =
        await getApplicationDocumentsDirectory();

    final path =
        '${directory.path}/$fileName';

    final savedImage =
        await File(
      image.path,
    ).copy(path);

    return savedImage;
  }

  /// PICK PROFILE IMAGE
  Future<void>
      pickProfileImage(
    ImageSource source,
  ) async {
    final XFile? image =
        await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image == null) return;

    final prefs =
        await SharedPreferences
            .getInstance();

    final savedImage =
        await _saveImage(
      image,
      'profile.jpg',
    );

    await prefs.setString(
      'profileImage',
      savedImage.path,
    );

    setState(() {
      profileImage =
          savedImage;
    });
  }

  /// PICK CERTIFICATE
  Future<void>
      pickCertificate(
    ImageSource source,
  ) async {
    final XFile? image =
        await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image == null) return;

    final prefs =
        await SharedPreferences
            .getInstance();

    final savedImage =
        await _saveImage(
      image,
      'certificate.jpg',
    );

    await prefs.setString(
      'certificateImage',
      savedImage.path,
    );

    setState(() {
      certificateImage =
          savedImage;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Certificate Uploaded Successfully',
        ),
      ),
    );
  }

  /// IMAGE PICKER
  void showImagePickerOptions(
    bool isProfile,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    );

                    isProfile
                        ? pickProfileImage(
                            ImageSource
                                .gallery,
                          )
                        : pickCertificate(
                            ImageSource
                                .gallery,
                          );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                  ),
                  title: const Text(
                    'Camera',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    );

                    isProfile
                        ? pickProfileImage(
                            ImageSource
                                .camera,
                          )
                        : pickCertificate(
                            ImageSource
                                .camera,
                          );
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// EDIT PROFILE
  void editProfileDialog() {
    final bloodController =
        TextEditingController(
      text: bloodGroup,
    );

    final donorController =
        TextEditingController(
      text: donorType,
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text(
              'Edit Profile',
            ),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                TextField(
                  controller:
                      bloodController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Blood Group',
                  ),
                ),
                const SizedBox(
                    height: 12),
                TextField(
                  controller:
                      donorController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Donor Type',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(
                        context),
                child: const Text(
                    'Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    () async {
                  setState(() {
                    bloodGroup =
                        bloodController
                            .text
                            .trim();

                    donorType =
                        donorController
                            .text
                            .trim();
                  });

                  await saveProfileData();

                  Navigator.pop(
                      context);
                },
                child:
                    const Text(
                  'Save',
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    final address =
        '$house $road $area $city'
            .trim();

    return Scaffold(
      backgroundColor:
          const Color(
              0xFFF5EFEF),

      body: SafeArea(
        child:
            SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                        20),
                decoration:
                    const BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.only(
                    bottomLeft:
                        Radius.circular(
                            25),
                    bottomRight:
                        Radius.circular(
                            25),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'My Profile',
                      style:
                          TextStyle(
                        color:
                            Colors.red,
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            28,
                      ),
                    ),

                    const SizedBox(
                        height: 15),

                    GestureDetector(
                      onTap: () {
                        showImagePickerOptions(
                            true);
                      },
                      child:
                          CircleAvatar(
                        radius: 55,
                        backgroundImage:
                            profileImage !=
                                    null
                                ? FileImage(
                                    profileImage!)
                                : null,
                        child:
                            profileImage ==
                                    null
                                ? const Icon(
                                    Icons
                                        .person,
                                    size:
                                        60,
                                  )
                                : null,
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    Text(
                      fullName,
                      style:
                          const TextStyle(
                        fontSize:
                            24,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    Text(
                      bloodGroup,
                    ),

                    const SizedBox(
                        height: 20),

                    _infoTile(
                        Icons.phone,
                        phone),
                    _infoTile(
                        Icons.email,
                        email),
                    _infoTile(
                      Icons.location_on,
                      address
                              .isEmpty
                          ? 'No address'
                          : address,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(
                context,
                AppRoutes
                    .dashboard,
              );
              break;

            case 1:
              Navigator.pushReplacementNamed(
                context,
                AppRoutes
                    .emergencyRequest,
              );
              break;

            case 3:
              Navigator.pushReplacementNamed(
                context,
                AppRoutes
                    .myRequest,
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
                Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.bloodtype),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.list),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String text,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
      ),
    );
  }
}