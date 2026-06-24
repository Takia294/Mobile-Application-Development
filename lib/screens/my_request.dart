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

class _MyRequestScreenState extends State<MyRequestScreen>
    with SingleTickerProviderStateMixin {
  bool _activeTab = true;

  /// Tracks which request IDs are currently being marked complete
  /// to prevent double-taps and show per-card loading spinners.
  final Set<String> _loadingIds = {};

  /// Optimistic local overrides: once the user confirms, we immediately
  /// mark the card as "Fulfilled" in the UI before Firestore confirms.
  final Set<String> _optimisticallyFulfilled = {};

  late final AnimationController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EEEE),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTitle(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 25),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────
  //  TITLE
  // ─────────────────────────────────────────────
  Widget _buildTitle() {
    return const Text(
      'My Requests',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TABS
  // ─────────────────────────────────────────────
  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabItem(
          label: 'Active Request',
          isSelected: _activeTab,
          underlineWidth: 110,
          onTap: () => setState(() => _activeTab = true),
        ),
        const SizedBox(width: 40),
        _tabItem(
          label: 'Past Request',
          isSelected: !_activeTab,
          underlineWidth: 90,
          onTap: () => setState(() => _activeTab = false),
        ),
      ],
    );
  }

  Widget _tabItem({
    required String label,
    required bool isSelected,
    required double underlineWidth,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.red : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: underlineWidth,
            height: 2,
            color: isSelected ? Colors.red : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BODY — StreamBuilder with real-time updates
  // ─────────────────────────────────────────────
  Widget _buildBody() {
    return StreamBuilder<List<RequestModel>>(
      stream: RequestDatabase.streamMyRequests(),
      builder: (context, snapshot) {
        // ── Loading ──
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        // ── Error ──
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'Something went wrong\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        final allRequests = snapshot.data ?? [];

        // Apply optimistic overrides so fulfilled IDs show immediately in Past tab
        final resolved = allRequests.map((r) {
          if (_optimisticallyFulfilled.contains(r.id)) {
            return r.copyWith(status: 'Fulfilled');
          }
          return r;
        }).toList();

        final activeRequests =
            resolved.where((r) => r.status != 'Fulfilled').toList();
        final completedRequests =
            resolved.where((r) => r.status == 'Fulfilled').toList();

        final list = _activeTab ? activeRequests : completedRequests;

        if (list.isEmpty) return _buildEmptyState(_activeTab);

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: ListView.builder(
            key: ValueKey(_activeTab),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: list.length + 1, // +1 for bottom spacing
            itemBuilder: (context, index) {
              if (index == list.length) return const SizedBox(height: 20);
              final request = list[index];
              return _activeTab
                  ? _activeRequestCard(request)
                  : _pastRequestCard(request);
            },
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────────
  Widget _buildEmptyState(bool isActive) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.inbox_outlined : Icons.history,
            size: 72,
            color: Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            isActive ? 'No Active Requests' : 'No Past Requests',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isActive
                ? 'Your active donation requests will appear here.'
                : 'Completed requests will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ACTIVE REQUEST CARD
  // ─────────────────────────────────────────────
  Widget _activeRequestCard(RequestModel request) {
    final isLoading = _loadingIds.contains(request.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Urgency-colored top strip ──
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _urgencyColor(request.urgency),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: icon + type + status badge ──
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.red.shade50,
                      child: Icon(
                        request.requestType == 'Organ Donation'
                            ? Icons.favorite_border
                            : Icons.water_drop_outlined,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        request.requestType,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _statusBadge(request.status),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // ── Details ──
                _detailRow(
                  icon: Icons.water_drop,
                  iconColor: Colors.red.shade700,
                  label: request.requestType == 'Organ Donation'
                      ? 'Organ'
                      : 'Blood Type',
                  value: request.requestType == 'Organ Donation'
                      ? request.organ
                      : request.bloodGroup,
                ),
                const SizedBox(height: 8),
                _detailRow(
                  icon: Icons.local_hospital_outlined,
                  iconColor: Colors.blue,
                  label: 'Hospital',
                  value: request.hospital,
                ),
                const SizedBox(height: 8),
                _detailRow(
                  icon: Icons.location_on_outlined,
                  iconColor: Colors.orange,
                  label: 'Address',
                  value: request.address,
                ),
                const SizedBox(height: 8),
                _detailRow(
                  icon: Icons.warning_amber_rounded,
                  iconColor: _urgencyColor(request.urgency),
                  label: 'Urgency',
                  value: request.urgency,
                  valueStyle: TextStyle(
                    color: _urgencyColor(request.urgency),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Mark as Complete button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 18),
                    label: Text(
                      isLoading ? 'Completing…' : 'Mark as Complete',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      disabledBackgroundColor: Colors.red.shade200,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed:
                        isLoading ? null : () => _confirmComplete(request),
                  ),
                ),

                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'In Progress',
                    style: TextStyle(color: Colors.black38, fontSize: 12),
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
  //  PAST REQUEST CARD
  // ─────────────────────────────────────────────
  Widget _pastRequestCard(RequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.green.shade50,
            child:
                const Icon(Icons.check_circle, color: Colors.green, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.requestType,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  request.requestType == 'Organ Donation'
                      ? 'Organ: ${request.organ}'
                      : 'Blood Type: ${request.bloodGroup}',
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                Text(
                  request.hospital,
                  style:
                      const TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  CONFIRM → MARK FULFILLED
  //  1. Optimistic local update (instant card move)
  //  2. Firestore updateStatus
  //  3. Increment admin Today's Donations counter
  // ─────────────────────────────────────────────
  Future<void> _confirmComplete(RequestModel request) async {
    if (request.id.isEmpty) {
      _showError('Invalid request ID. Please try again.');
      return;
    }

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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // ── Show spinner on this card only ──
    setState(() {
      _loadingIds.add(request.id);
      // Optimistic: move card to Past immediately
      _optimisticallyFulfilled.add(request.id);
    });

    try {
      // 1️⃣  Update status in Firestore → triggers StreamBuilder rebuild
      await RequestDatabase.updateStatus(
        requestId: request.id,
        newStatus: 'Fulfilled',
      );

      // 2️⃣  Increment Today's Donations in admin_stats
      await RequestDatabase.incrementTodaysDonations();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('✅ Request marked as complete!'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Switch to Past tab
      setState(() => _activeTab = false);
    } catch (e) {
      if (!mounted) return;

      // Roll back the optimistic update on failure
      setState(() => _optimisticallyFulfilled.remove(request.id));
      _showError('Failed to complete request: $e');
    } finally {
      if (mounted) setState(() => _loadingIds.remove(request.id));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM NAV
  // ─────────────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const EmergencyRequestScreen()));
        } else if (index == 3) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const MyProfileScreen()));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: ''),
        BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  SMALL HELPERS
  // ─────────────────────────────────────────────
  Widget _detailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: valueStyle ??
                const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
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

  Color _urgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.deepOrange;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green; // Low
    }
  }
}