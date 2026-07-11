import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/screen_routes.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// ============================================================
/// NOTIFICATION SCREEN
/// Previously fully hardcoded/static. Now streams real documents
/// from the `notifications` collection via NotificationService,
/// while keeping the original visual design (urgent banner style
/// for 'urgent' type, standard cards for everything else).
/// ============================================================
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int currentIndex = 3;

  void _onNavTap(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.emergencyRequest);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.myRequest);
        break;
      case 3:
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.myProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EDED),
      body: SafeArea(
        child: StreamBuilder<List<NotificationModel>>(
          stream: NotificationService.streamMyNotifications(),
          builder: (context, snap) {
            final items = snap.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Notification",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC62828),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Stay updated on life-saving request",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 25),

                  /// MARK ALL BUTTON
                  SizedBox(
                    width: 170,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: items.isEmpty
                          ? null
                          : () => NotificationService.markAllAsRead(items),
                      child: const Text(
                        "Mark all as read",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (snap.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(color: Color(0xFFC62828)),
                    )
                  else if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: const [
                          Icon(Icons.notifications_none,
                              size: 64, color: Colors.black26),
                          SizedBox(height: 12),
                          Text(
                            "You're all caught up!",
                            style: TextStyle(color: Colors.black45, fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "New alerts about requests and events\nwill show up here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black26, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else
                    ...items.map((n) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: n.type == 'urgent'
                              ? _urgentCard(n)
                              : _notificationCard(n),
                        )),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _urgentCard(NotificationModel n) {
    return GestureDetector(
      onTap: () => NotificationService.markAsRead(n.id),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFDE2D22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text("🚨", style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          )),
                      if (n.subtitle.isNotEmpty)
                        Text(n.subtitle,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B0000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.findDonor),
                    child: Text(
                      n.buttonText.isEmpty ? "Respond Now" : n.buttonText,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
                Text(n.timeAgo, style: const TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard(NotificationModel n) {
    IconData icon;
    Color iconColor;
    switch (n.type) {
      case 'fulfilled':
        icon = Icons.check_box;
        iconColor = Colors.green;
        break;
      case 'event':
        icon = Icons.event;
        iconColor = Colors.blue;
        break;
      default:
        icon = Icons.favorite;
        iconColor = Colors.red;
    }

    return GestureDetector(
      onTap: () => NotificationService.markAsRead(n.id),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isReadBy(FirebaseAuth.instance.currentUser?.uid)
              ? Colors.white
              : const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  if (n.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(n.subtitle,
                          style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ),
                  if (n.buttonText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(100, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {},
                        child: Text(n.buttonText,
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                ],
              ),
            ),
            Text(n.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
