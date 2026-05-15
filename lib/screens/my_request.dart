import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// ACTIVE REQUESTS
  List<Map<String, String>> activeRequests = [];

  /// COMPLETED REQUESTS
  List<Map<String, String>> completedRequests = [];

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  /// LOAD ALL REQUESTS
  Future<void> loadRequests() async {

    final prefs =
        await SharedPreferences.getInstance();

    /// ACTIVE REQUESTS
    List<String> activeList =
        prefs.getStringList(
              'requests',
            ) ??
            [];

    /// COMPLETED REQUESTS
    List<String> completedList =
        prefs.getStringList(
              'completed_requests',
            ) ??
            [];

    setState(() {

      activeRequests =
          activeList.map((e) {

        List<String> data = e.split('|');

        return {
          'type': data[0],
          'blood': data[1],
          'hospital': data[2],
          'address': data[3],
          'urgency': data[4],
        };

      }).toList();

      completedRequests =
          completedList.map((e) {

        List<String> data = e.split('|');

        return {
          'type': data[0],
          'blood': data[1],
          'hospital': data[2],
          'address': data[3],
          'urgency': data[4],
        };

      }).toList();
    });
  }

  /// COMPLETE REQUEST
  Future<void> completeRequest(
      int index) async {

    final prefs =
        await SharedPreferences.getInstance();

    List<String> activeList =
        prefs.getStringList(
              'requests',
            ) ??
            [];

    List<String> completedList =
        prefs.getStringList(
              'completed_requests',
            ) ??
            [];

    /// MOVE ACTIVE TO COMPLETED
    completedList.add(
      activeList[index],
    );

    activeList.removeAt(index);

    await prefs.setStringList(
      'requests',
      activeList,
    );

    await prefs.setStringList(
      'completed_requests',
      completedList,
    );

    loadRequests();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Request Completed Successfully',
        ),
      ),
    );
  }

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
                        width: 90,
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
                        'Past Request',

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
                        width: 80,
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

                    /// ACTIVE REQUESTS
                    if (activeTab) ...[

                      activeRequests.isEmpty

                          ? const Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(
                                  top: 80,
                                ),

                                child: Text(
                                  'No Active Requests',

                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            )

                          : Column(
                              children:
                                  List.generate(
                                activeRequests.length,

                                (index) {

                                  final request =
                                      activeRequests[index];

                                  return Container(

                                    margin:
                                        const EdgeInsets.only(
                                      bottom: 18,
                                    ),

                                    padding:
                                        const EdgeInsets.all(
                                      14,
                                    ),

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors.white,

                                      borderRadius:
                                          BorderRadius.circular(
                                        18,
                                      ),
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [

                                        /// TITLE
                                        Row(
                                          children: [

                                            const Icon(
                                              Icons.person_outline,
                                              size: 30,
                                            ),

                                            const SizedBox(
                                                width: 10),

                                            Expanded(
                                              child: Text(
                                                request['type']!,
                                                style:
                                                    const TextStyle(
                                                  fontSize:
                                                      20,

                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
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
                                              color:
                                                  Colors.red.shade700,

                                              size: 35,
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
                                                    'Blood Type: ${request['blood']}',

                                                    style:
                                                        const TextStyle(
                                                      fontSize:
                                                          16,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height: 4),

                                                  Text(
                                                    request['hospital']!,

                                                    style:
                                                        const TextStyle(
                                                      color:
                                                          Colors.black54,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height: 4),

                                                  Text(
                                                    request['address']!,

                                                    style:
                                                        const TextStyle(
                                                      color:
                                                          Colors.black54,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height: 8),

                                                  Text(
                                                    'Status : ${request['urgency']}',

                                                    style:
                                                        const TextStyle(
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
                                            ),
                                          ],
                                        ),

                                        const SizedBox(
                                            height: 20),

                                        /// COMPLETE BUTTON
                                        SizedBox(
                                          width:
                                              double.infinity,

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
                                                  10,
                                                ),
                                              ),
                                            ),

                                            onPressed: () {
                                              completeRequest(
                                                index,
                                              );
                                            },

                                            child:
                                                const Text(
                                              'Mark as Complete',

                                              style:
                                                  TextStyle(
                                                color:
                                                    Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 10),

                                        const Center(
                                          child: Text(
                                            'In Progress',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],

                    /// PAST REQUESTS
                    if (!activeTab) ...[

                      completedRequests.isEmpty

                          ? const Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(
                                  top: 80,
                                ),

                                child: Text(
                                  'No Past Requests',

                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            )

                          : Column(
                              children:
                                  List.generate(
                                completedRequests.length,

                                (index) {

                                  final request =
                                      completedRequests[index];

                                  return _pastRequestCard(
                                    title:
                                        request['type']!,
                                    blood:
                                        request['blood']!,
                                    location:
                                        request['hospital']!,
                                    status:
                                        'Completed',
                                  );
                                },
                              ),
                            ),
                    ],

                    const SizedBox(height: 20),
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
            icon:
                Icon(Icons.home_outlined),
            label: '',
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.edit_note),
            label: '',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment_outlined,
            ),
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
          18,
        ),
      ),

      child: Row(
        children: [

          CircleAvatar(
            radius: 28,

            backgroundColor:
                Colors.red.shade100,

            child: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
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
                  'Blood Type : $blood',

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