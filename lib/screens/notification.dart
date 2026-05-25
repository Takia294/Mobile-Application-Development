import 'package:flutter/material.dart';
import '../routes/screen_routes.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {
  int currentIndex = 3;

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
          const Color(0xFFF8EDED),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 18,
          ),
          child: Column(
            children: [
              /// TITLE
              const SizedBox(height: 10),

              const Text(
                "Notification",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFFC62828),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Stay updated on life-saving request",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              /// MARK ALL BUTTON
              SizedBox(
                width: 170,
                height: 40,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Mark all as read",
                    style: TextStyle(
                      color:
                          Colors.black87,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// URGENT
              _urgentCard(),

              const SizedBox(height: 12),

              _notificationCard(
                icon: Icons.check_box,
                iconColor: Colors.green,
                title:
                    "Your last donation request was fulfilled successfully",
                time: "2h ago",
              ),

              const SizedBox(height: 12),

              _notificationCard(
                icon: Icons.favorite,
                iconColor: Colors.red,
                title:
                    "Kidney donor",
                subtitle:
                    "need urgently at Green Valley Hospital. Paired organ donation encouraged.",
                buttonText:
                    "View details",
                time: "8h ago",
              ),

              const SizedBox(height: 12),

              _notificationCard(
                icon: Icons.favorite,
                iconColor: Colors.red,
                title:
                    "Join our upcoming donor meetup on June 5",
                subtitle:
                    "at Community Center. Connect with fellow donors and learn more!",
                buttonText:
                    "Register Now",
                time: "1 day ago",
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex:
            currentIndex,
        type:
            BottomNavigationBarType
                .fixed,
        selectedItemColor:
            Colors.black,
        unselectedItemColor:
            Colors.grey,
        showSelectedLabels:
            false,
        showUnselectedLabels:
            false,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.edit_note),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.list_alt),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.notifications),
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

  Widget _urgentCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            const Color(0xFFDE2D22),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "🚨",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      "Urgent: Blood type O-",
                      style:
                          TextStyle(
                        color: Colors
                            .white,
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            15,
                      ),
                    ),
                    Text(
                      "needed in City Hospital",
                      style:
                          TextStyle(
                        color: Colors
                            .white70,
                        fontSize:
                            12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              SizedBox(
                height: 30,
                child:
                    ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                            0xFF9B0000),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Respond Now",
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
              const Text(
                "5 min ago",
                style: TextStyle(
                  color:
                      Colors.white,
                  fontSize: 11,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _notificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    String? subtitle,
    String? buttonText,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                12),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 28,
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
                        FontWeight
                            .bold,
                    fontSize: 14,
                  ),
                ),

                if (subtitle !=
                    null)
                  Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      top: 4,
                    ),
                    child: Text(
                      subtitle,
                      style:
                          const TextStyle(
                        fontSize:
                            12,
                        color: Colors
                            .black54,
                      ),
                    ),
                  ),

                if (buttonText !=
                    null)
                  Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      top: 10,
                    ),
                    child:
                        ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red,
                        minimumSize:
                            const Size(
                                100,
                                30),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                      ),
                      onPressed:
                          () {},
                      child: Text(
                        buttonText,
                        style:
                            const TextStyle(
                          color: Colors
                              .white,
                          fontSize:
                              12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}