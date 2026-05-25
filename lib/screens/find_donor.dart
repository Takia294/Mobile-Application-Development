import 'package:flutter/material.dart';
import '../routes/screen_routes.dart';

class FindDonorScreen extends StatefulWidget {
  const FindDonorScreen({super.key});

  @override
  State<FindDonorScreen> createState() =>
      _FindDonorScreenState();
}

class _FindDonorScreenState
    extends State<FindDonorScreen> {
  int currentIndex = 0;

  String selectedBlood = 'Blood Type A+';
  String selectedDistance = 'Within 5 Km';

  final List<Map<String, String>>
      donors = [
    {
      "name": "Rahim Khan",
      "blood": "A+",
      "distance":
          "2 Km away • Available now",
    },
    {
      "name": "Shara Ahmed",
      "blood": "AB+",
      "distance":
          "5 Km away • Available now",
    },
    {
      "name": "Ali Hossain",
      "blood": "B-",
      "distance":
          "7 Km away • Available now",
    },
  ];

  void _onNavTap(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dashboard,
        );
        break;

      case 1:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.emergencyRequest,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8EFEF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              /// HEADER
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Find Donors Nearby',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                        color: Color(
                            0xFFD9534F),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Find available blood donors around you",
                      style: TextStyle(
                        color:
                            Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// FILTERS
              Row(
                children: [
                  Expanded(
                    child:
                        _buildDropdown(
                      value:
                          selectedBlood,
                      items: const [
                        'Blood Type A+',
                        'Blood Type B+',
                        'Blood Type O+',
                        'Blood Type AB+',
                      ],
                      onChanged:
                          (value) {
                        setState(() {
                          selectedBlood =
                              value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(
                      width: 10),

                  Expanded(
                    child:
                        _buildDropdown(
                      value:
                          selectedDistance,
                      items: const [
                        'Within 5 Km',
                        'Within 10 Km',
                        'Within 20 Km',
                      ],
                      onChanged:
                          (value) {
                        setState(() {
                          selectedDistance =
                              value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// MAP SECTION
              Container(
                height: 250,
                width: double.infinity,
                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius
                          .circular(
                              18),
                ),
                clipBehavior:
                    Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://i.imgur.com/4sP9L7G.png',
                      fit: BoxFit.cover,
                    ),

                    const Positioned(
                      top: 40,
                      left: 60,
                      child: Icon(
                        Icons
                            .location_on,
                        color:
                            Colors.red,
                        size: 38,
                      ),
                    ),

                    const Positioned(
                      top: 100,
                      right: 50,
                      child: Icon(
                        Icons
                            .medical_services,
                        color:
                            Colors.purple,
                        size: 34,
                      ),
                    ),

                    const Positioned(
                      bottom: 60,
                      left: 120,
                      child: Icon(
                        Icons
                            .location_on,
                        color:
                            Colors.red,
                        size: 38,
                      ),
                    ),

                    Positioned(
                      bottom: 18,
                      left: 95,
                      child: Container(
                        padding:
                            const EdgeInsets
                                .all(10),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black12,
                              blurRadius:
                                  8,
                            ),
                          ],
                        ),
                        child:
                            const Column(
                          children: [
                            Text(
                              "City Hospital",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize:
                                    12,
                              ),
                            ),
                            Text(
                              "Nearby Center",
                              style:
                                  TextStyle(
                                fontSize:
                                    11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// DONORS TITLE
              const Text(
                "Available Donors",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              /// DONOR LIST
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    donors.length,
                itemBuilder:
                    (context, index) {
                  final donor =
                      donors[index];

                  return Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      bottom: 12,
                    ),
                    child: _donorCard(
                      donor["name"]!,
                      donor["blood"]!,
                      donor[
                          "distance"]!,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      /// BOTTOM NAVBAR
      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex:
            currentIndex,
        type:
            BottomNavigationBarType
                .fixed,
        selectedItemColor:
            Colors.red,
        unselectedItemColor:
            Colors.grey,
        onTap: _onNavTap,
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
            icon:
                Icon(Icons.list_alt),
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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return Container(
      height: 55,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF3E8E8),
        borderRadius:
            BorderRadius.circular(
                14),
      ),
      child:
          DropdownButtonHideUnderline(
        child:
            DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) =>
                    DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    overflow:
                        TextOverflow
                            .ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _donorCard(
    String name,
    String blood,
    String distance,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(14),
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
          CircleAvatar(
            radius: 28,
            backgroundColor:
                Colors.red.shade50,
            child: const Icon(
              Icons.person,
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
                  name,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Blood Group: $blood",
                ),
                Text(
                  distance,
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                            10),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "Contact",
              style: TextStyle(
                color:
                    Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}