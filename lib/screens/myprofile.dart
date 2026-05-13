import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'emergency_request.dart';

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
    });
  }

  /// SAVE PROFILE INFO
  Future<void> saveProfileData() async {
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

  /// PICK PROFILE IMAGE
  Future<void> pickProfileImage(
    ImageSource source,
  ) async {
    final XFile? image =
        await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        profileImage = File(
          image.path,
        );
      });
    }
  }

  /// PICK CERTIFICATE
  Future<void> pickCertificate(
    ImageSource source,
  ) async {
    final XFile? image =
        await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        certificateImage = File(
          image.path,
        );
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Certificate Uploaded Successfully',
          ),
        ),
      );
    }
  }

  /// IMAGE PICK OPTIONS
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

                    if (isProfile) {
                      pickProfileImage(
                        ImageSource
                            .gallery,
                      );
                    } else {
                      pickCertificate(
                        ImageSource
                            .gallery,
                      );
                    }
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

                    if (isProfile) {
                      pickProfileImage(
                        ImageSource
                            .camera,
                      );
                    } else {
                      pickCertificate(
                        ImageSource
                            .camera,
                      );
                    }
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
          (context) => AlertDialog(
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
                  height: 12,
                ),

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
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },

                child: const Text(
                  'Cancel',
                ),
              ),

              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    bloodGroup =
                        bloodController
                            .text;

                    donorType =
                        donorController
                            .text;
                  });

                  await saveProfileData();

                  Navigator.pop(
                    context,
                  );
                },

                child: const Text(
                  'Save',
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
            0xFFF5EFEF,
          ),

      body: SafeArea(
        child:
            SingleChildScrollView(
              child: Column(
                children: [
                  /// TOP SECTION
                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets.only(
                          top: 20,
                          bottom: 20,
                        ),

                    decoration:
                        const BoxDecoration(
                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.only(
                                bottomLeft:
                                    Radius.circular(
                                      25,
                                    ),
                                bottomRight:
                                    Radius.circular(
                                      25,
                                    ),
                              ),
                        ),

                    child: Column(
                      children: [
                        const Text(
                          'My profile',

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
                          height: 15,
                        ),

                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,

                              backgroundColor:
                                  Colors
                                      .teal
                                      .shade200,

                              backgroundImage:
                                  profileImage !=
                                          null
                                      ? FileImage(
                                        profileImage!,
                                      )
                                      : null,

                              child:
                                  profileImage ==
                                          null
                                      ? const Icon(
                                        Icons
                                            .person,
                                        size:
                                            70,
                                        color:
                                            Colors.white,
                                      )
                                      : null,
                            ),

                            Positioned(
                              bottom: 0,
                              right: 0,

                              child:
                                  GestureDetector(
                                    onTap: () {
                                      showImagePickerOptions(
                                        true,
                                      );
                                    },

                                    child:
                                        Container(
                                          padding:
                                              const EdgeInsets.all(
                                                8,
                                              ),

                                          decoration:
                                              const BoxDecoration(
                                                color:
                                                    Colors.red,

                                                shape:
                                                    BoxShape.circle,
                                              ),

                                          child:
                                              const Icon(
                                                Icons
                                                    .edit,
                                                color:
                                                    Colors.white,
                                                size:
                                                    18,
                                              ),
                                        ),
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        Text(
                          fullName,

                          style:
                              const TextStyle(
                                fontSize:
                                    26,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        GestureDetector(
                          onTap:
                              editProfileDialog,

                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal:
                                      20,
                                  vertical:
                                      8,
                                ),

                            decoration:
                                BoxDecoration(
                                  color:
                                      Colors.red,

                                  borderRadius:
                                      BorderRadius.circular(
                                        20,
                                      ),
                                ),

                            child: Text(
                              bloodGroup ==
                                          'None'
                                      ? 'Edit Profile'
                                      : '$bloodGroup Donor',

                              style:
                                  const TextStyle(
                                    color:
                                        Colors.white,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        /// INFO CARD
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal:
                                    12,
                              ),

                          child: Column(
                            children: [
                              _infoTile(
                                Icons.phone,
                                phone,
                              ),

                              _infoTile(
                                Icons.email,
                                email,
                              ),

                              _infoTile(
                                Icons.location_on,
                                '$house $road $area $city',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        /// BUTTONS
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal:
                                    10,
                              ),

                          child: Row(
                            children: [
                              Expanded(
                                child:
                                    ElevatedButton(
                                      style:
                                          ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red,
                                          ),

                                      onPressed:
                                          () {
                                            Navigator.push(
                                              context,

                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) =>
                                                        const EmergencyRequestScreen(),
                                              ),
                                            );
                                          },

                                      child:
                                          const Text(
                                            'Respond to Blood Request',

                                            style:
                                                TextStyle(
                                                  color:
                                                      Colors.white,

                                                  fontSize:
                                                      11,
                                                ),
                                          ),
                                    ),
                              ),

                              const SizedBox(
                                width:
                                    8,
                              ),

                              Expanded(
                                child:
                                    ElevatedButton(
                                      style:
                                          ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.purple,
                                          ),

                                      onPressed:
                                          () {
                                            Navigator.push(
                                              context,

                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) =>
                                                        const EmergencyRequestScreen(),
                                              ),
                                            );
                                          },

                                      child:
                                          const Text(
                                            'Respond to Organ Request',

                                            style:
                                                TextStyle(
                                                  color:
                                                      Colors.white,

                                                  fontSize:
                                                      11,
                                                ),
                                          ),
                                    ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          'In Progress',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// DONATION HISTORY
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                              12,
                        ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        const Text(
                          'Donation History',

                          style:
                              TextStyle(
                                fontSize:
                                    22,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        _historyCard(
                          '1 Jan, 2026',
                          'Blood Donation',
                          'City Hospital - 2.5 Km away',
                        ),

                        _historyCard(
                          '10 Mar, 2025',
                          'Kidney Donation',
                          'City Hospital - 2.5 Km away',
                        ),

                        _historyCard(
                          '1 Jan, 2026',
                          'Blood Donation',
                          'Green Clinic - 2.5 Km away',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  /// CERTIFICATE
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                              12,
                        ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        const Text(
                          'DOP Certificate',

                          style:
                              TextStyle(
                                fontSize:
                                    22,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        SizedBox(
                          width:
                              double.infinity,

                          height: 50,

                          child:
                              ElevatedButton.icon(
                                style:
                                    ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.red,

                                      shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                  25,
                                                ),
                                          ),
                                    ),

                                onPressed: () {
                                  showImagePickerOptions(
                                    false,
                                  );
                                },

                                icon:
                                    const Icon(
                                      Icons
                                          .upload,
                                      color:
                                          Colors.white,
                                    ),

                                label:
                                    const Text(
                                      'Upload Donor Certificate',

                                      style:
                                          TextStyle(
                                            color:
                                                Colors.white,

                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                    ),
                              ),
                        ),

                        if (certificateImage !=
                            null)
                          Padding(
                            padding:
                                const EdgeInsets.only(
                                  top:
                                      15,
                                ),

                            child:
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),

                                  child:
                                      Image.file(
                                        certificateImage!,

                                        height:
                                            180,

                                        width:
                                            double.infinity,

                                        fit:
                                            BoxFit.cover,
                                      ),
                                ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
      ),

      /// BOTTOM NAVBAR
      bottomNavigationBar:
          BottomNavigationBar(
            currentIndex: 3,

            type:
                BottomNavigationBarType
                    .fixed,

            selectedItemColor:
                Colors.black,

            unselectedItemColor:
                Colors.black54,

            showSelectedLabels:
                false,

            showUnselectedLabels:
                false,

            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,

                  MaterialPageRoute(
                    builder:
                        (
                          context,
                        ) =>
                            const DashboardScreen(),
                  ),
                );
              }

              if (index == 1) {
                Navigator.pushReplacement(
                  context,

                  MaterialPageRoute(
                    builder:
                        (
                          context,
                        ) =>
                            const EmergencyRequestScreen(),
                  ),
                );
              }
            },

            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_outlined,
                ),
                label: '',
              ),

              BottomNavigationBarItem(
                icon: Icon(
                  Icons.edit_note,
                ),
                label: '',
              ),

              BottomNavigationBarItem(
                icon: Icon(
                  Icons.assignment_outlined,
                ),
                label: '',
              ),

              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                ),
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
    return Container(
      margin:
          const EdgeInsets.only(
            bottom: 8,
          ),

      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
            color:
                const Color(
                  0xFFF1EAEA,
                ),

            borderRadius:
                BorderRadius.circular(
                  10,
                ),
          ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              text.isEmpty
                  ? 'None'
                  : text,

              style:
                  const TextStyle(
                    fontSize: 16,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(
    String date,
    String title,
    String location,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
            bottom: 10,
          ),

      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(
            color:
                const Color(
                  0xFFF1EAEA,
                ),

            borderRadius:
                BorderRadius.circular(
                  12,
                ),
          ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                Colors.red.shade200,

            child: const Icon(
              Icons.favorite,
              color: Colors.white,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  '$date - $title',

                  style:
                      const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  location,

                  style:
                      const TextStyle(
                        color:
                            Colors.black54,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}