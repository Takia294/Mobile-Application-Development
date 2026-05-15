import 'package:flutter/material.dart';

import '../routes/screen_routes.dart';
import 'emergency_request.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7EFEF),

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
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

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(
                    'Welcome Dear',
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Let’s make a difference together",
                    style: TextStyle(
                      color:
                          Colors.white70,
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
                    const EdgeInsets.all(
                        16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    /// GOOD MORNING
                    const Text(
                      'Good Morning 👋',
                      style: TextStyle(
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
                      style: TextStyle(
                        color:
                            Colors.black54,
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

                                  style:
                                      TextStyle(
                                    fontSize:
                                        13,
                                  ),
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

                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              10),
                                    ),
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

                      crossAxisCount: 2,

                      crossAxisSpacing:
                          15,

                      mainAxisSpacing:
                          15,

                      childAspectRatio:
                          2.2,

                      children: [

                        /// FIND DONOR
                        _quickAction(
                          context,

                          icon:
                              Icons.search,

                          title:
                              'Find Donors',

                          onTap: () {
                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Find Donor Coming Soon',
                                ),
                              ),
                            );
                          },
                        ),

                        /// BOOK REQUEST
                        _quickAction(
                          context,

                          icon:
                              Icons.bloodtype,

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

                        /// MY REQUEST
                        _quickAction(
                          context,

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

                        /// CENTER
                        _quickAction(
                          context,

                          icon:
                              Icons.phone,

                          title:
                              'Center',

                          onTap: () {
                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
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

                    /// NEARBY HOSPITAL
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
                              () {},

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

                    Container(
                      padding:
                          const EdgeInsets
                              .all(14),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                                0xFFF0EAEA),

                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),
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

                              color:
                                  Colors.red,

                              size: 30,
                            ),
                          ),

                          const SizedBox(
                              width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  'City Hospital',

                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize:
                                        15,
                                  ),
                                ),

                                SizedBox(
                                    height:
                                        5),

                                Text(
                                  '2 Km away - Open 24/7',

                                  style:
                                      TextStyle(
                                    color:
                                        Colors.grey,
                                    fontSize:
                                        12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.add,

                            color:
                                Colors.red,

                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAVIGATION
      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: 0,

        type:
            BottomNavigationBarType
                .fixed,

        selectedItemColor:
            Colors.red,

        unselectedItemColor:
            Colors.grey,

        showSelectedLabels:
            false,

        showUnselectedLabels:
            false,

        onTap: (index) {

          /// HOME
          if (index == 0) {}

          /// REQUEST
          else if (index == 1) {
            Navigator.pushNamed(
              context,
              AppRoutes
                  .emergencyRequest,
            );
          }

          /// MY REQUEST
          else if (index == 2) {
            Navigator.pushNamed(
              context,
              AppRoutes.myRequest,
            );
          }

          /// PROFILE
          else if (index == 3) {
            Navigator.pushNamed(
              context,
              AppRoutes.myProfile,
            );
          }
        },

        items: const [

          BottomNavigationBarItem(
            icon:
                Icon(Icons.home),
            label: '',
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.edit_note),
            label: '',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '',
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }

  /// QUICK ACTION WIDGET
  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {

    return InkWell(
      borderRadius:
          BorderRadius.circular(16),

      onTap: onTap,

      child: Container(
        padding:
            const EdgeInsets.all(
                14),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
                  16),

          boxShadow: [

            BoxShadow(
              color: Colors.black
                  .withOpacity(0.05),

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
                      FontWeight.bold,
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