import 'package:flutter/material.dart';

import '../routes/screen_routes.dart';
import 'dashboard.dart';
import 'emergency_request.dart';
import 'myprofile.dart';

class MyRequestScreen extends StatefulWidget {
  const MyRequestScreen({super.key});

  @override
  State<MyRequestScreen> createState() =>
      _MyRequestScreenState();
}

class _MyRequestScreenState
    extends State<MyRequestScreen> {

  bool activeTab = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4EEEE),

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 20),

            /// TITLE
            const Text(
              'My Requests',
              style: TextStyle(
                fontSize: 34,
                fontWeight:
                    FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            /// TABS
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [

                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeTab = true;
                    });
                  },

                  child: Column(
                    children: [

                      Text(
                        'Active Request',
                        style: TextStyle(
                          color: activeTab
                              ? Colors.red
                              : Colors.black54,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 4),

                      Container(
                        width: 70,
                        height: 2,
                        color: activeTab
                            ? Colors.red
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 40),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeTab = false;
                    });
                  },

                  child: Column(
                    children: [

                      Text(
                        'Past request',
                        style: TextStyle(
                          color: !activeTab
                              ? Colors.red
                              : Colors.black54,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 4),

                      Container(
                        width: 70,
                        height: 2,
                        color: !activeTab
                            ? Colors.red
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    /// ACTIVE REQUEST
                    if (activeTab) ...[

                      Container(
                        padding:
                            const EdgeInsets.all(
                                14),

                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                                  18),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Row(
                              children: [

                                const Icon(
                                  Icons.person_outline,
                                  size: 30,
                                ),

                                const SizedBox(
                                    width: 10),

                                const Text(
                                  'Blood Donation Request',
                                  style:
                                      TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 18),

                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Icon(
                                  Icons.water_drop,
                                  color: Colors.red
                                      .shade700,
                                  size: 35,
                                ),

                                const SizedBox(
                                    width: 12),

                                const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(
                                      'Blood Type: A+',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            16,
                                      ),
                                    ),

                                    SizedBox(
                                        height:
                                            4),

                                    Text(
                                      'City Hospital - 2Km away',
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.black54,
                                      ),
                                    ),

                                    SizedBox(
                                        height:
                                            8),

                                    Text(
                                      'Status : Urgent',
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.red,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 20),

                            /// BUTTONS
                            Row(
                              children: [

                                Expanded(
                                  child:
                                      ElevatedButton(
                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.red,

                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
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
                                    width: 8),

                                Expanded(
                                  child:
                                      ElevatedButton(
                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blue,

                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
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

                            const SizedBox(
                                height: 12),

                            const Center(
                              child: Text(
                                'in progress',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 25),

                    /// PAST REQUESTS
                    const Text(
                      'Past requests',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _pastRequestCard(
                      image:
                          'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',

                      title:
                          'Blood Donation Request',

                      blood:
                          'Blood Type : O-',

                      location:
                          'Metro Hospital - 2Km away',

                      status:
                          'Status : Donated',
                    ),

                    _pastRequestCard(
                      image:
                          'https://cdn-icons-png.flaticon.com/512/387/387561.png',

                      title:
                          'Organ Donation Request',

                      blood:
                          'Kidney Donation',

                      location:
                          'Green Hospital - 5 Km away',

                      status:
                          'Status : Completed',
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAVBAR
      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: 2,

        type:
            BottomNavigationBarType.fixed,

        selectedItemColor:
            Colors.black,

        unselectedItemColor:
            Colors.black54,

        showSelectedLabels: false,
        showUnselectedLabels:
            false,

        onTap: (index) {

          if (index == 0) {
            Navigator.pushReplacement(
              context,

              MaterialPageRoute(
                builder: (context) =>
                    const DashboardScreen(),
              ),
            );
          }

          else if (index == 1) {
            Navigator.pushReplacement(
              context,

              MaterialPageRoute(
                builder: (context) =>
                    const EmergencyRequestScreen(),
              ),
            );
          }

          else if (index == 3) {
            Navigator.pushReplacement(
              context,

              MaterialPageRoute(
                builder: (context) =>
                    const MyProfileScreen(),
              ),
            );
          }
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: '',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: '',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }

  /// PAST REQUEST CARD
  Widget _pastRequestCard({
    required String image,
    required String title,
    required String blood,
    required String location,
    required String status,
  }) {

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                18),
      ),

      child: Row(
        children: [

          CircleAvatar(
            radius: 28,
            backgroundColor:
                Colors.red.shade100,

            backgroundImage:
                NetworkImage(image),
          ),

          const SizedBox(width: 12),

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
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  blood,
                  style:
                      const TextStyle(
                    color:
                        Colors.black54,
                  ),
                ),

                Text(
                  location,
                  style:
                      const TextStyle(
                    color:
                        Colors.black54,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  status,
                  style:
                      TextStyle(
                    color:
                        Colors.green
                            .shade600,

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 20,
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