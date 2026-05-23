import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/screen_routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  String userName = "User";
  Timer? _timer;

  final List<Map<String, String>>
      hospitals = [
    {
      "name":
          "Dhaka Medical College Hospital",
      "distance":
          "2.5 Km away - Open 24/7"
    },
    {
      "name": "Square Hospital",
      "distance":
          "3 Km away - Open 24/7"
    },
    {
      "name":
          "Evercare Hospital Dhaka",
      "distance":
          "4 Km away - Open 24/7"
    },
    {
      "name": "United Hospital",
      "distance":
          "5 Km away - Open 24/7"
    },
    {
      "name":
          "Popular Diagnostic Center",
      "distance":
          "2 Km away - Open"
    },
    {
      "name": "Ibn Sina Hospital",
      "distance":
          "3.2 Km away - Open"
    },
  ];

  @override
  void initState() {
    super.initState();
    loadUserName();

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

  /// LOAD USER NAME
  Future<void> loadUserName() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    if (!mounted) return;

    final name =
        prefs.getString('fullName');

    setState(() {
      userName =
          (name != null &&
                  name.trim().isNotEmpty)
              ? name
              : "User";
    });
  }

  /// GREETING
  String getGreeting() {
    final hour =
        DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
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

  /// HOSPITAL SHEET
  void showHospitals() {
    showModalBottomSheet(
      context: context,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              const Text(
                "Dhaka Hospitals",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                  height: 15),

              ...hospitals.map(
                (hospital) => Card(
                  child: ListTile(
                    leading:
                        const Icon(
                      Icons
                          .local_hospital,
                      color:
                          Colors.red,
                    ),
                    title: Text(
                      hospital[
                          "name"]!,
                    ),
                    subtitle: Text(
                      hospital[
                          "distance"]!,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// NAVIGATION
  void _navigateTo(int index) {
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
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7EFEF),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets
                      .fromLTRB(
                20,
                15,
                20,
                28,
              ),
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFFF5757),
                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(
                          22),
                  bottomRight:
                      Radius.circular(
                          22),
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

            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
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
                    ),

                    const SizedBox(
                        height: 22),

                    /// EMERGENCY CARD
                    Container(
                      width: double
                          .infinity,
                      padding:
                          const EdgeInsets
                              .all(16),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                                0xFFF4EEEE),
                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Emergency Donation Request',
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
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
                                            0xFFFF5757),
                                  ),
                                  onPressed:
                                      () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.emergencyRequest,
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

                          Image.network(
                            'https://cdn-icons-png.flaticon.com/512/3209/3209265.png',
                            height:
                                90,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        height: 30),

                    /// QUICK ACTIONS
                    const Text(
                      'Quick Actions',
                      style:
                          TextStyle(
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
                      shrinkWrap:
                          true,
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
                          Icons.search,
                          'Find Donors',
                          () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.findDonor,
                            );
                          },
                        ),

                        _quickAction(
                          Icons
                              .bloodtype,
                          'Book Request',
                          () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.emergencyRequest,
                            );
                          },
                        ),

                        _quickAction(
                          Icons
                              .warning_amber_rounded,
                          'My Request',
                          () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.myRequest,
                            );
                          },
                        ),

                        _quickAction(
                          Icons.phone,
                          'Center',
                          () {},
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 30),

                    /// HOSPITAL
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
                                Colors.grey,
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
                            ),
                          ),
                        ),
                      ],
                    ),

                    hospitalCard(
                      "Square Hospital",
                      "3 Km away - Open 24/7",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor:
            Colors.red,
        unselectedItemColor:
            Colors.grey,
        type:
            BottomNavigationBarType
                .fixed,
        onTap: _navigateTo,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.bloodtype),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
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

  Widget hospitalCard(
    String title,
    String subtitle,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF0EAEA),
        borderRadius:
            BorderRadius.circular(
                12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor:
                Colors.white,
            child: Icon(
              Icons.local_hospital,
              color: Colors.red,
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
                        FontWeight.bold,
                  ),
                ),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
              16),
      child: Container(
        padding:
            const EdgeInsets.all(
                14),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
                  16),
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
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}