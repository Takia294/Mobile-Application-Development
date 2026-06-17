import 'package:flutter/material.dart';

import '../models/request_model.dart';
import '../services/request_database.dart';
import 'dashboard.dart';
import 'emergency_request.dart';
import 'myprofile.dart';

class MyRequestScreen extends StatefulWidget {
  const MyRequestScreen({super.key});

  @override
  State<MyRequestScreen> createState() => _MyRequestScreenState();
}

class _MyRequestScreenState extends State<MyRequestScreen> {
  bool activeTab = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EEEE),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// TITLE
            const Text(
              'My Requests',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            /// TABS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => activeTab = true),
                  child: Column(
                    children: [
                      Text(
                        'Active Request',
                        style: TextStyle(
                          color: activeTab ? Colors.red : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 110,
                        height: 2,
                        color: activeTab ? Colors.red : Colors.transparent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () => setState(() => activeTab = false),
                  child: Column(
                    children: [
                      Text(
                        'Past Request',
                        style: TextStyle(
                          color: !activeTab ? Colors.red : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 90,
                        height: 2,
                        color: !activeTab ? Colors.red : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// LIVE STREAM OF USER'S REQUESTS FROM FIRESTORE
            Expanded(
              child: StreamBuilder<List<RequestModel>>(
                stream: RequestDatabase.streamMyRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Something went wrong\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  final allRequests = snapshot.data ?? [];

                  // Active = everything NOT Fulfilled
                  final activeRequests = allRequests
                      .where((r) => r.status != 'Fulfilled')
                      .toList();

                  // Past = only Fulfilled
                  final completedRequests = allRequests
                      .where((r) => r.status == 'Fulfilled')
                      .toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ACTIVE REQUESTS TAB
                        if (activeTab) ...[
                          activeRequests.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 80),
                                    child: Column(
                                      children: [
                                        Icon(Icons.inbox_outlined,
                                            size: 60, color: Colors.black26),
                                        SizedBox(height: 12),
                                        Text(
                                          'No Active Requests',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: activeRequests
                                      .map((r) => _activeRequestCard(r))
                                      .toList(),
                                ),
                        ],

                        /// PAST REQUESTS TAB
                        if (!activeTab) ...[
                          completedRequests.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 80),
                                    child: Column(
                                      children: [
                                        Icon(Icons.history,
                                            size: 60, color: Colors.black26),
                                        SizedBox(height: 12),
                                        Text(
                                          'No Past Requests',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: completedRequests
                                      .map((r) => _pastRequestCard(request: r))
                                      .toList(),
                                ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const EmergencyRequestScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MyProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ACTIVE REQUEST CARD
  // ─────────────────────────────────────────────
  Widget _activeRequestCard(RequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header row: icon + title + status badge
          Row(
            children: [
              const Icon(Icons.person_outline, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  request.requestType,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _statusBadge(request.status),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.water_drop, color: Colors.red.shade700, size: 35),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requestType == 'Organ Donation'
                          ? 'Organ: ${request.organ}'
                          : 'Blood Type: ${request.bloodGroup}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(request.hospital,
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(request.address,
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text(
                      'Urgency : ${request.urgency}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Mark as Complete button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 18),
              label: const Text('Mark as Complete',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _confirmComplete(request),
            ),
          ),

          const SizedBox(height: 8),
          const Center(
            child: Text('In Progress',
                style: TextStyle(color: Colors.black45, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  CONFIRM & MARK FULFILLED  →  also updates
  //  admin dashboard "Today's Donations" counter
  // ─────────────────────────────────────────────
  Future<void> _confirmComplete(RequestModel request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark as Complete'),
        content:
            const Text('Are you sure this request has been fulfilled?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // 1️⃣  Update request status → 'Fulfilled'
      await RequestDatabase.updateStatus(
        requestId: request.id,
        newStatus: 'Fulfilled',
      );

      // 2️⃣  Increment today's donation count in admin dashboard
      await RequestDatabase.incrementTodaysDonations();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('✅ Request Completed Successfully'),
          duration: Duration(seconds: 3),
        ),
      );

      // Auto-switch to Past Requests tab
      setState(() => activeTab = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $e'),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  //  PAST REQUEST CARD  (reads from RequestModel)
  // ─────────────────────────────────────────────
  Widget _pastRequestCard({required RequestModel request}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green.shade100,
            child: const Icon(Icons.check_circle, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.requestType,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  request.requestType == 'Organ Donation'
                      ? 'Organ: ${request.organ}'
                      : 'Blood Type: ${request.bloodGroup}',
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(request.hospital,
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Text(
                  'Completed ✓',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────
  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'critical':
        return Colors.red;
      case 'fulfilled':
        return Colors.blue;
      default:
        return Colors.orange; // Pending
    }
  }
}