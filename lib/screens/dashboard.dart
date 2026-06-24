import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes/screen_routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  /// USER NAME
  String userName = "User";

  /// TIMER
  Timer? _timer;

  /// CURRENT BOTTOM NAV INDEX
  int currentIndex = 0;

  /// HOSPITAL LIST
  final List<Map<String, String>>
      hospitals = [
    {
      "name":
          "Dhaka Medical College Hospital",
      "distance":
          "2.5 Km away - Open 24/7",
    },
    {
      "name": "Square Hospital",
      "distance":
          "3 Km away - Open 24/7",
    },
    {
      "name":
          "Evercare Hospital Dhaka",
      "distance":
          "4 Km away - Open 24/7",
    },
    {
      "name": "United Hospital",
      "distance":
          "5 Km away - Open 24/7",
    },
    {
      "name":
          "Popular Diagnostic Center",
      "distance":
          "2 Km away - Open",
    },
    {
      "name": "Ibn Sina Hospital",
      "distance":
          "3.2 Km away - Open",
    },
  ];

  @override
  void initState() {
    super.initState();

    loadUserName();

    /// AUTO GREETING UPDATE
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// LOAD USER NAME FROM FIRESTORE
  Future<void> loadUserName() async {
    try {
      final user =
          FirebaseAuth.instance
              .currentUser;

      if (user == null) return;

      final doc =
          await FirebaseFirestore
              .instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!doc.exists) return;

      final data = doc.data();

      if (!mounted) return;

      setState(() {
        userName =
            data?['fullName']
                    ?.toString() ??
                "User";
      });
    } catch (e) {
      debugPrint(
        "LOAD USER ERROR: $e",
      );
    }
  }

  /// GREETING FUNCTION
  String getGreeting() {
    final hour =
        DateTime.now().hour;

    if (hour >= 5 &&
        hour < 12) {
      return "Good Morning 👋";
    } else if (hour >= 12 &&
        hour < 17) {
      return "Good Afternoon ☀️";
    } else if (hour >= 17 &&
        hour < 21) {
      return "Good Evening 🌇";
    } else {
      return "Good Night 🌙";
    }
  }

  /// SHOW HOSPITAL LIST
  void showHospitals() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder:
          (context) => Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Center(
              child: Text(
                "Dhaka Hospitals",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
                height: 20),

            ...hospitals.map(
              (hospital) =>
                  Card(
                elevation: 2,
                child: ListTile(
                  leading:
                      const CircleAvatar(
                    backgroundColor:
                        Color(
                      0xFFFFEBEE,
                    ),
                    child: Icon(
                      Icons
                          .local_hospital,
                      color:
                          Colors.red,
                    ),
                  ),
                  title: Text(
                    hospital["name"]!,
                  ),
                  subtitle: Text(
                    hospital["distance"]!,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FIXED NAVIGATION
  void _navigate(int index) {
    /// SAME TAB CLICK
    if (currentIndex == index) {
      return;
    }

    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 0:
        break;

      case 1:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes
              .emergencyRequest,
        );
        break;

      case 2:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.myRequest,
        );
        break;

      case 3:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.notification,
        );
        break;

      case 4:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.myProfile,
        );
        break;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF7EFEF,
      ),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 28,
              ),
              decoration:
                  const BoxDecoration(
                color:
                    Color(
                  0xFFFF5757,
                ),
                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(
                    22,
                  ),
                  bottomRight:
                      Radius.circular(
                    22,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Welcome $userName',
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),

                  const SizedBox(
                      height: 6),

                  const Text(
                    "Let’s make a difference together",
                    style:
                        TextStyle(
                      color: Colors
                          .white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            /// BODY
            Expanded(
              child:
                  SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    /// GREETING
                    Text(
                      getGreeting(),
                      style:
                          const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                        height: 5),

                    const Text(
                      "Don’t worry, We are always there for you",
                      style:
                          TextStyle(
                        color:
                            Colors
                                .black54,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(
                        height: 22),

                    /// EMERGENCY CARD
                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF4EEEE,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Emergency Donation Request',
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize:
                                        16,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        8),

                                const Text(
                                  'Urgent: Blood type A+ or kidney needed',
                                ),

                                const SizedBox(
                                    height:
                                        14),

                                ElevatedButton(
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(
                                      0xFFFF5757,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                  ),
                                  onPressed:
                                      () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes
                                          .emergencyRequest,
                                    );
                                  },
                                  child:
                                      const Text(
                                    'Respond to Request',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                              width: 12),

                          Image.network(
                            'https://cdn-icons-png.flaticon.com/512/3209/3209265.png',
                            height: 90,
                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons
                                    .bloodtype,
                                size: 70,
                                color:
                                    Colors.red,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        height: 30),

                    /// QUICK ACTIONS
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color:
                            Colors.grey,
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    GridView.count(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisCount:
                          2,
                      crossAxisSpacing:
                          15,
                      mainAxisSpacing:
                          15,
                      childAspectRatio:
                          2.2,
                      children: [
                        _quickAction(
                          icon:
                              Icons.search,
                          title:
                              'Find Donors',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes
                                  .findDonor,
                            );
                          },
                        ),

                        _quickAction(
                          icon: Icons
                              .bloodtype,
                          title:
                              'Book Request',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes
                                  .emergencyRequest,
                            );
                          },
                        ),

                        _quickAction(
                          icon: Icons
                              .warning_amber_rounded,
                          title:
                              'My Request',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes
                                  .myRequest,
                            );
                          },
                        ),

                        _quickAction(
                          icon:
                              Icons.phone,
                          title: 'Center',
                          onTap: () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Center List Coming Soon',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 30),

                    /// HOSPITAL HEADER
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          'Nearby Hospital',
                          style:
                              TextStyle(
                            color:
                                Colors
                                    .grey,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize:
                                18,
                          ),
                        ),

                        TextButton(
                          onPressed:
                              showHospitals,
                          child:
                              const Text(
                            'See All >',
                            style:
                                TextStyle(
                              color:
                                  Colors.red,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    hospitalCard(
                      "Square Hospital",
                      "3 Km away - Open 24/7",
                    ),

                    const SizedBox(
                        height: 12),

                    hospitalCard(
                      "Evercare Hospital",
                      "4 Km away - Open 24/7",
                    ),

                    const SizedBox(
                        height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAVIGATION BAR
      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex:
            currentIndex,
        selectedItemColor:
            Colors.red,
        unselectedItemColor:
            Colors.grey,
        type:
            BottomNavigationBarType
                .fixed,
        onTap: _navigate,
        items: const [
          BottomNavigationBarItem(
            icon:
                Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(
                Icons.bloodtype),
            label: 'Request',
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.list),
            label: 'My Request',
          ),

          BottomNavigationBarItem(
            icon: Icon(
                Icons.notifications),
            label:
                'Notification',
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// HOSPITAL CARD
  Widget hospitalCard(
    String title,
    String subtitle,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF0EAEA,
        ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor:
                Colors.white,
            child: Icon(
              Icons
                  .local_hospital,
              color: Colors.red,
              size: 30,
            ),
          ),

          const SizedBox(
              width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                    height: 5),

                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.add,
            color: Colors.red,
            size: 30,
          ),
        ],
      ),
    );
  }

  /// QUICK ACTION WIDGET
  Widget _quickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(
        16,
      ),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.all(
          14,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(
                0.05,
              ),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 35,
              color: Colors.red,
            ),

            const SizedBox(
                width: 10),

            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}