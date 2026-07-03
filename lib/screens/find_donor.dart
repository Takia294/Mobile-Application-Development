import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/donor_model.dart';
import '../routes/screen_routes.dart';
import '../services/donor_service.dart';
import '../services/location_service.dart';

/// ============================================================
/// FIND DONOR SCREEN
///
/// BUG FIX: previously queried donorType whereIn ['Blood','Organ',
/// 'Both'] while MyProfileScreen actually saves 'Blood Donor' /
/// 'Organ Donor' / 'Both' / 'None' — so no donor ever matched.
/// All filtering now goes through DonorService, the single source
/// of truth for donorType values.
///
/// MAP: uses flutter_map + OpenStreetMap tiles, which are free and
/// require no API key (unlike Google Maps, which needs a billing
/// account). Donors who've shared their location appear as pins;
/// tapping a pin opens the same contact sheet as the list view.
/// ============================================================
class FindDonorScreen extends StatefulWidget {
  const FindDonorScreen({super.key});
  @override
  State<FindDonorScreen> createState() => _FindDonorScreenState();
}

class _FindDonorScreenState extends State<FindDonorScreen> {
  String _selectedBlood = 'All';
  String _searchQuery = '';
  bool _showMap = false;
  final _searchCtrl = TextEditingController();
  final MapController _mapController = MapController();

  Position? _myPosition;
  bool _loadingLocation = false;
  String? _locationError;

  static const _bloodGroups = [
    'All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  static const LatLng _dhakaFallback = LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();
    _loadMyLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMyLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });
    try {
      final pos = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _myPosition = pos);
    } catch (e) {
      if (!mounted) return;
      setState(() => _locationError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  LatLng get _mapCenter => _myPosition != null
      ? LatLng(_myPosition!.latitude, _myPosition!.longitude)
      : _dhakaFallback;

  List<DonorModel> _applyLocalFilters(List<DonorModel> donors) {
    var list = donors;
    if (_searchQuery.isNotEmpty) {
      list = list.where((d) {
        return d.fullName.toLowerCase().contains(_searchQuery) ||
            d.location.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    if (_myPosition != null) {
      list = DonorService.sortByDistance(
        list,
        fromLat: _myPosition!.latitude,
        fromLng: _myPosition!.longitude,
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EFEF),
      appBar: AppBar(
        title: const Text('Find Donors'),
        actions: [
          IconButton(
            tooltip: _showMap ? 'List view' : 'Map view',
            icon: Icon(_showMap ? Icons.list_alt : Icons.map_outlined),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: Column(children: [
        // Search + filter
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(children: [
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name or area…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        })
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _bloodGroups.map((b) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedBlood = b),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _selectedBlood == b
                            ? const Color(0xFFE53935) : const Color(0xFFF3EFEF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(b,
                          style: TextStyle(
                              color: _selectedBlood == b
                                  ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ),
                  ),
                )).toList(),
              ),
            ),
            if (_locationError != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.location_off, size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Showing donors without distance sorting — $_locationError',
                    style: const TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ),
                TextButton(
                  onPressed: _loadMyLocation,
                  child: const Text('Retry', style: TextStyle(fontSize: 11)),
                ),
              ]),
            ],
          ]),
        ),

        // Donor list / map from Firestore
        Expanded(
          child: StreamBuilder<List<DonorModel>>(
            stream: DonorService.streamDonors(bloodGroup: _selectedBlood),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE53935)));
              }
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Could not load donors.\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black45),
                    ),
                  ),
                );
              }

              final donors = _applyLocalFilters(snap.data ?? []);

              if (donors.isEmpty) {
                return Center(child: Column(
                    mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.person_search,
                      size: 64, color: Colors.black12),
                  const SizedBox(height: 12),
                  Text(
                    _selectedBlood == 'All'
                        ? 'No donors found yet'
                        : 'No donors with blood type $_selectedBlood',
                    style: const TextStyle(
                        color: Colors.black38, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text(
                    'Donors appear here once they set their\ndonor type in My Profile.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black26, fontSize: 12),
                  ),
                ]));
              }

              return _showMap
                  ? _buildMap(donors)
                  : _buildList(donors);
            },
          ),
        ),
      ]),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFE53935),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          const routes = [
            AppRoutes.dashboard, AppRoutes.emergencyRequest,
            AppRoutes.myRequest, AppRoutes.notification, AppRoutes.myProfile,
          ];
          if (i != 0) Navigator.pushReplacementNamed(context, routes[i]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),        label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bloodtype_outlined),   label: 'Request'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined),    label: 'My Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined),label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),       label: 'Profile'),
        ],
      ),
    );
  }

  // ── LIST VIEW ──
  Widget _buildList(List<DonorModel> donors) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      itemCount: donors.length,
      itemBuilder: (_, i) => _donorCard(donors[i]),
    );
  }

  // ── MAP VIEW (free OpenStreetMap via flutter_map, no API key) ──
  Widget _buildMap(List<DonorModel> donors) {
    final locatable = donors.where((d) => d.hasLocation).toList();

    final markers = <Marker>[
      if (_myPosition != null)
        Marker(
          point: LatLng(_myPosition!.latitude, _myPosition!.longitude),
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
        ),
      ...locatable.map((d) => Marker(
            point: LatLng(d.latitude!, d.longitude!),
            width: 42,
            height: 42,
            child: GestureDetector(
              onTap: () => _showContactSheet(d),
              child: const Icon(Icons.location_on,
                  color: Color(0xFFE53935), size: 38),
            ),
          )),
    ];

    return Stack(children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _mapCenter,
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.lifelink.donation_app',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      if (locatable.isEmpty)
        Positioned(
          bottom: 16, left: 16, right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'None of the matching donors have shared their location yet. '
              'Switch to list view to see and contact them.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ),
      Positioned(
        bottom: 16, right: 16,
        child: FloatingActionButton.small(
          backgroundColor: Colors.white,
          onPressed: () => _mapController.move(_mapCenter, 12),
          child: _loadingLocation
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location, color: Color(0xFFE53935)),
        ),
      ),
    ]);
  }

  Widget _donorCard(DonorModel donor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFFFEBEE),
          backgroundImage:
              donor.profileImage.isNotEmpty ? NetworkImage(donor.profileImage) : null,
          child: donor.profileImage.isEmpty
              ? Text(donor.fullName.isNotEmpty ? donor.fullName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.bold,
                      fontSize: 20))
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(donor.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 3),
          Row(children: [
            if (donor.bloodGroup.isNotEmpty)
              _badge(donor.bloodGroup, const Color(0xFFE53935)),
            const SizedBox(width: 6),
            _badge(donor.donorType, Colors.blue),
          ]),
          if (donor.location.isNotEmpty || donor.distanceKm != null) ...[
            const SizedBox(height: 3),
            Text(
              [
                donor.location,
                if (donor.distanceKm != null)
                  LocationService.formatDistance(donor.distanceKm),
              ].where((s) => s.isNotEmpty).join(' • '),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ])),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(80, 36),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _showContactSheet(donor),
          child: const Text('Contact', style: TextStyle(fontSize: 12)),
        ),
      ]),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(color: color,
              fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _showContactSheet(DonorModel donor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10)),
          ),
          Text('Contact ${donor.fullName}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(children: [
            _badge(donor.bloodGroup.isEmpty ? '—' : donor.bloodGroup,
                const Color(0xFFE53935)),
            const SizedBox(width: 6),
            _badge(donor.donorType, Colors.blue),
          ]),
          const SizedBox(height: 20),
          if (donor.phone.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _callDonor(donor.phone),
                icon: const Icon(Icons.call, color: Colors.white),
                label: const Text('Call Now',
                    style: TextStyle(color: Colors.white)),
              ),
            )
          else
            const Text('This donor has not shared a phone number yet.',
                style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _callDonor(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the phone dialer.')),
      );
    }
  }
}
