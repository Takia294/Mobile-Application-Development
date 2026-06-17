import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/request_database.dart';
import '../routes/screen_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Live snapshot caches ──
  List<QueryDocumentSnapshot> _users = [];
  List<RequestModel> _requests = [];
  List<QueryDocumentSnapshot> _donations = [];
  List<QueryDocumentSnapshot> _complaints = [];
  int _todayDonationsLive = 0;

  // ── Subscriptions ──
  final List<StreamSubscription> _subs = [];

  // ── Search ──
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ── Last-refresh timestamp ──
  DateTime _lastRefresh = DateTime.now();
  late Timer _clockTimer;

  @override
  void initState() {
    super.initState();
    _subscribeAll();
    // Rebuild every second so "last updated X seconds ago" stays live
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _subscribeAll() {
    _subs.add(_db.collection('users').snapshots().listen((s) {
      if (mounted) setState(() { _users = s.docs; _lastRefresh = DateTime.now(); });
    }));

    // ── Requests: go through RequestDatabase so this screen and the
    // ── user app (MyRequestScreen / EmergencyRequestScreen) always
    // ── agree on shape + status values (Active/Pending/Critical/Fulfilled).
    _subs.add(RequestDatabase.streamAllRequests().listen((reqs) {
      if (mounted) setState(() { _requests = reqs; _lastRefresh = DateTime.now(); });
    }));

    _subs.add(_db.collection('donations').snapshots().listen((s) {
      if (mounted) setState(() { _donations = s.docs; _lastRefresh = DateTime.now(); });
    }));
    _subs.add(_db.collection('complaints').snapshots().listen((s) {
      if (mounted) setState(() { _complaints = s.docs; _lastRefresh = DateTime.now(); });
    }));

    // ── Today's Donations: this is the SAME counter that
    // ── RequestDatabase.incrementTodaysDonations() bumps when a user
    // ── marks a request as Fulfilled in MyRequestScreen. Reading it via
    // ── RequestDatabase.streamTodaysDonationCount() keeps both screens
    // ── pointed at the exact same Firestore document, so the stat card
    // ── updates live the moment a request is completed.
    _subs.add(RequestDatabase.streamTodaysDonationCount().listen((count) {
      if (mounted) setState(() { _todayDonationsLive = count; _lastRefresh = DateTime.now(); });
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) s.cancel();
    _clockTimer.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────
  // Computed values
  // ────────────────────────────────────────────
  int get _totalUsers => _users.length;
  int get _activeRequests =>
      _requests.where((r) => r.status == 'Active').length;
  int get _pendingComplaints =>
      _complaints.where((c) => (c['status'] ?? '') == 'Pending').length;

  // Today's donations now comes live from RequestDatabase (see _subscribeAll),
  // fed by RequestDatabase.incrementTodaysDonations() whenever a user marks
  // their request as Fulfilled. This replaces the old (disconnected) version
  // that counted documents in a separate `donations` collection.
  int get _todayDonations => _todayDonationsLive;

  String get _sinceSecs {
    final diff = DateTime.now().difference(_lastRefresh).inSeconds;
    if (diff < 5) return 'just now';
    return '${diff}s ago';
  }

  List<QueryDocumentSnapshot> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((u) {
      final name = (u['fullName'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) || email.contains(_searchQuery);
    }).toList();
  }

  Map<int, int> get _monthlyDonations {
    final map = <int, int>{for (int i = 1; i <= 12; i++) i: 0};
    for (final d in _donations) {
      final ts = (d.data() as Map)['createdAt'];
      if (ts is Timestamp) {
        final m = ts.toDate().month;
        map[m] = (map[m] ?? 0) + 1;
      }
    }
    return map;
  }

  // ────────────────────────────────────────────
  // Actions
  // ────────────────────────────────────────────
  Future<void> _logout() async {
    final ok = await _confirmDialog('Logout', 'Are you sure you want to logout?');
    if (ok) {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<void> _deleteUser(String uid, String name) async {
    final ok = await _confirmDialog('Delete User', 'Delete "$name"? This cannot be undone.');
    if (ok) {
      await _db.collection('users').doc(uid).delete();
      _snack('User "$name" deleted', isError: true);
    }
  }

  Future<void> _updateRequestStatus(String docId, String status) async {
    // Routed through RequestDatabase so user-side screens (which also use
    // RequestDatabase) see the same update instantly via their own streams.
    await RequestDatabase.updateStatus(requestId: docId, newStatus: status);

    // If an admin manually marks a request Fulfilled from this dashboard,
    // also bump the same Today's Donations counter the user flow uses,
    // so the stat card stays accurate regardless of who completed it.
    if (status == 'Fulfilled') {
      await RequestDatabase.incrementTodaysDonations();
    }

    _snack('Status updated to $status', isSuccess: true);
  }

  Future<void> _deleteRequest(String docId) async {
    final ok = await _confirmDialog('Delete Request', 'Delete this request? This cannot be undone.');
    if (ok) {
      await RequestDatabase.deleteRequest(docId);
      _snack('Request deleted', isError: true);
    }
  }

  Future<bool> _confirmDialog(String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(title, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _snack(String msg, {bool isSuccess = false, bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? Colors.green : isError ? Colors.red : Colors.black87,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: const Color(0xFFE53935),
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live status chip
              _liveChip(),
              const SizedBox(height: 14),

              // Stat cards
              _statGrid(),
              const SizedBox(height: 18),

              // User management
              _sectionHeader('User Management', Icons.people_alt_outlined,
                  subtitle: '${_totalUsers} registered'),
              const SizedBox(height: 10),
              _userManagementCard(),
              const SizedBox(height: 18),

              // Request monitoring
              _sectionHeader('Request Monitoring', Icons.monitor_heart_outlined,
                  subtitle: '${_requests.length} total'),
              const SizedBox(height: 10),
              _requestMonitoringCard(),
              const SizedBox(height: 18),

              // Report & Analysis
              _sectionHeader('Report & Analysis', Icons.analytics_outlined),
              const SizedBox(height: 10),
              _reportCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  // AppBar
  // ────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFE53935),
      elevation: 0,
      centerTitle: true,
      title: const Column(
        children: [
          Text('Admin Dashboard',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
          Text('Manage Requests, Users & Alerts',
              style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => _snack('Settings coming soon'),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  // Live chip
  // ────────────────────────────────────────────
  Widget _liveChip() {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('Live  ·  Updated $_sinceSecs',
            style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ────────────────────────────────────────────
  // Section header
  // ────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon, {String? subtitle}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE53935), size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const Spacer(),
        if (subtitle != null)
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // ────────────────────────────────────────────
  // Stat grid (pure data, no StreamBuilder needed)
  // ────────────────────────────────────────────
  Widget _statGrid() {
    final cards = [
      _StatData('Total Users', _totalUsers, Icons.people, Colors.blue),
      _StatData('Active Requests', _activeRequests, Icons.list_alt, const Color(0xFFE53935)),
      _StatData("Today's Donations", _todayDonations, Icons.favorite, Colors.green),
      _StatData('Pending Complaints', _pendingComplaints, Icons.warning_amber_rounded, Colors.orange),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) {
        final c = cards[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: c.color.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(c.icon, color: Colors.white, size: 28),
              const SizedBox(height: 6),
              Text(c.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  '${c.count}',
                  key: ValueKey(c.count),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────
  // User Management Card
  // ────────────────────────────────────────────
  Widget _userManagementCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name or email…',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Table header
          _tableHeader(const ['Name', 'Blood', 'Actions'], const [3, 2, 3]),

          // Rows
          _filteredUsers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child: Text('No users found', style: TextStyle(color: Colors.grey))),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredUsers.length > 8 ? 8 : _filteredUsers.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 14, endIndent: 14),
                  itemBuilder: (_, i) {
                    final u = _filteredUsers[i];
                    final uid = u.id;
                    final name = (u['fullName'] ?? 'Unknown').toString();
                    final blood = (u['bloodGroup'] ?? '').toString();
                    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        children: [
                          // Name col
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      const Color(0xFFE53935).withOpacity(0.12),
                                  child: Text(initials,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFE53935),
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.w600)),
                                      Text((u['email'] ?? '').toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Blood col
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: blood.isEmpty
                                  ? const Text('N/A',
                                      style: TextStyle(fontSize: 11, color: Colors.grey))
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color:
                                            const Color(0xFFE53935).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(blood,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFFE53935),
                                              fontWeight: FontWeight.bold)),
                                    ),
                            ),
                          ),

                          // Actions col
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _miniBtn('Info', Colors.blue,
                                    () => _showUserInfo(u)),
                                const SizedBox(width: 4),
                                _miniBtn('Delete', Colors.red,
                                    () => _deleteUser(uid, name)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

          // "Show all" footer
          if (_filteredUsers.length > 8)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '+${_filteredUsers.length - 8} more users',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFFE53935), fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Request Monitoring Card
  // ────────────────────────────────────────────
  Widget _requestMonitoringCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        children: [
          _tableHeader(
            const ['Type', 'Blood/Organ', 'Hospital', 'Status', 'Action'],
            const [2, 2, 2, 2, 2],
          ),
          _requests.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child: Text('No requests yet', style: TextStyle(color: Colors.grey))),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _requests.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 10, endIndent: 10),
                  itemBuilder: (_, i) {
                    final req = _requests[i];
                    final docId = req.id;
                    final status = req.status;
                    final type = req.requestType;
                    final details = req.requestType == 'Organ Donation'
                        ? req.organ
                        : req.bloodGroup;
                    final hospital = req.hospital;

                    final statusColor = _statusColor(status);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(type,
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis)),
                          Expanded(
                              flex: 2,
                              child: Text(details,
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis)),
                          Expanded(
                              flex: 2,
                              child: Text(hospital,
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis)),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 3),
                              decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(status,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: statusColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () => _showStatusPicker(docId, status),
                              onLongPress: () => _deleteRequest(docId),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Text('Manage',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Report Card
  // ────────────────────────────────────────────
  Widget _reportCard() {
    final monthly = _monthlyDonations;
    final maxVal = monthly.values.fold(0, (a, b) => a > b ? a : b);
    final chartMax = maxVal < 5 ? 5 : maxVal + 2;
    const monthLabels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    const barColors = [
      Color(0xFFE53935), Colors.blue, Colors.purple, Colors.orange,
      Colors.teal, Colors.pink, Color(0xFFE53935), Colors.indigo,
      Colors.cyan, Colors.amber, Colors.lime, Colors.brown,
    ];

    // Request breakdown — now driven by RequestModel.requestType so it
    // matches the values actually written by EmergencyRequestScreen
    // ('Blood Donation' / 'Organ Donation').
    int blood = 0, organ = 0, plasma = 0, other = 0;
    for (final r in _requests) {
      final t = r.requestType.toLowerCase();
      if (t.contains('blood')) blood++;
      else if (t.contains('organ')) organ++;
      else if (t.contains('plasma')) plasma++;
      else other++;
    }
    final total = blood + organ + plasma + other;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly bar chart
          const Text('Monthly Donations',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 14),

          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$chartMax', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    Text('${chartMax ~/ 2}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    const Text('0', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(12, (i) {
                      final count = monthly[i + 1] ?? 0;
                      final barH =
                          chartMax == 0 ? 2.0 : (count / chartMax) * 110;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (count > 0)
                            Text('$count',
                                style: const TextStyle(
                                    fontSize: 8, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 18,
                            height: barH < 2 ? 2 : barH,
                            decoration: BoxDecoration(
                              color: barColors[i],
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(monthLabels[i],
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.grey)),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 14),

          // Request breakdown
          const Text('Request Type Breakdown',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _legendBar('Blood', blood, total, Colors.red),
                    const SizedBox(height: 8),
                    _legendBar('Organ', organ, total, Colors.blue),
                    const SizedBox(height: 8),
                    _legendBar('Plasma', plasma, total, Colors.purple),
                    const SizedBox(height: 8),
                    _legendBar('Other', other, total, Colors.orange),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dot('Blood', blood, Colors.red),
                  _dot('Organ', organ, Colors.blue),
                  _dot('Plasma', plasma, Colors.purple),
                  _dot('Other', other, Colors.orange),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Dialogs / Sheets
  // ────────────────────────────────────────────
  void _showUserInfo(QueryDocumentSnapshot user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.person_outline, color: Color(0xFFE53935)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                (user['fullName'] ?? 'User Info').toString(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dlgRow(Icons.email_outlined, 'Email', user['email']),
              _dlgRow(Icons.phone_outlined, 'Phone', user['phone']),
              _dlgRow(Icons.bloodtype_outlined, 'Blood Group', user['bloodGroup']),
              _dlgRow(Icons.cake_outlined, 'DOB', user['dob']),
              _dlgRow(Icons.wc_outlined, 'Gender', user['gender']),
              _dlgRow(Icons.location_on_outlined, 'City', user['city']),
              _dlgRow(Icons.volunteer_activism_outlined, 'Donor Type', user['donorType']),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showStatusPicker(String docId, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Update Request Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            for (final s in ['Active', 'Pending', 'Critical', 'Fulfilled'])
              ListTile(
                leading: CircleAvatar(
                    radius: 8, backgroundColor: _statusColor(s)),
                title: Text(s, style: const TextStyle(fontSize: 14)),
                trailing: current == s
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () async {
                  Navigator.pop(context);
                  await _updateRequestStatus(docId, s);
                },
              ),
            const Divider(height: 20),
            ListTile(
              leading: const CircleAvatar(
                  radius: 8, backgroundColor: Colors.black54),
              title: const Text('Delete Request',
                  style: TextStyle(fontSize: 14, color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _deleteRequest(docId);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  // Small helpers
  // ────────────────────────────────────────────
  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'active': return Colors.green;
      case 'critical': return Colors.red;
      case 'fulfilled': return Colors.blue;
      default: return Colors.orange;
    }
  }

  Widget _tableHeader(List<String> labels, List<int> flexes) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(labels.length, (i) => Expanded(
          flex: flexes[i],
          child: Text(labels[i],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        )),
      ),
    );
  }

  Widget _miniBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _dlgRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFE53935)),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
              child: Text((value ?? 'N/A').toString(),
                  style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _legendBar(String label, int count, int total, Color color) {
    final pct = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(width: 42, child: Text(label, style: const TextStyle(fontSize: 11))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withOpacity(0.12),
              color: color,
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 32,
          child: Text('${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _dot(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label: $count', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Simple data class ──
class _StatData {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  const _StatData(this.title, this.count, this.icon, this.color);
}