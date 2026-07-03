import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../routes/screen_routes.dart';
import '../services/location_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // ── Firebase instances ──
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  // ── State ──
  bool isLoading = true;
  bool isUploadingProfile = false;
  bool isUploadingCertificate = false;

  // ── User data ──
  String fullName = '';
  String email = '';
  String phone = '';
  String house = '';
  String road = '';
  String area = '';
  String city = '';
  String bloodGroup = '';
  String donorType = '';
  String gender = '';
  String dob = '';
  String profileImageUrl = '';
  String certificateImageUrl = '';
  double? latitude;
  double? longitude;
  bool isUpdatingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ── LOAD DATA FROM FIRESTORE ──
  Future<void> _loadUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          fullName = data['fullName'] ?? '';
          email = data['email'] ?? '';
          phone = data['phone'] ?? '';
          house = data['house'] ?? '';
          road = data['road'] ?? '';
          area = data['area'] ?? '';
          city = data['city'] ?? '';
          bloodGroup = data['bloodGroup'] ?? '';
          donorType = data['donorType'] ?? '';
          gender = data['gender'] ?? '';
          dob = data['dob'] ?? '';
          profileImageUrl = data['profileImage'] ?? '';
          certificateImageUrl = data['certificateImage'] ?? '';
          latitude = (data['latitude'] as num?)?.toDouble();
          longitude = (data['longitude'] as num?)?.toDouble();
        });
      }
    } catch (e) {
      _showSnackBar('Failed to load profile data');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ── UPLOAD IMAGE TO FIREBASE STORAGE ──
  Future<String?> _uploadImageToStorage(XFile image, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // ── PICK & UPLOAD PROFILE IMAGE ──
  Future<void> _pickProfileImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 75);
    if (image == null) return;

    setState(() => isUploadingProfile = true);

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final url = await _uploadImageToStorage(image, 'profiles/$uid/profile.jpg');

    if (url != null) {
      await _firestore.collection('users').doc(uid).update({'profileImage': url});
      if (mounted) setState(() => profileImageUrl = url);
      _showSnackBar('Profile photo updated!', isSuccess: true);
    } else {
      _showSnackBar('Failed to upload image');
    }

    if (mounted) setState(() => isUploadingProfile = false);
  }

  // ── PICK & UPLOAD CERTIFICATE ──
  Future<void> _pickCertificate(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 75);
    if (image == null) return;

    setState(() => isUploadingCertificate = true);

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final url = await _uploadImageToStorage(image, 'profiles/$uid/certificate.jpg');

    if (url != null) {
      await _firestore.collection('users').doc(uid).update({'certificateImage': url});
      if (mounted) setState(() => certificateImageUrl = url);
      _showSnackBar('Certificate uploaded!', isSuccess: true);
    } else {
      _showSnackBar('Failed to upload certificate');
    }

    if (mounted) setState(() => isUploadingCertificate = false);
  }

  // ── IMAGE SOURCE PICKER BOTTOM SHEET ──
  void _showImageOptions(bool isProfile) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                isProfile ? 'Update Profile Photo' : 'Upload Certificate',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.photo_library, color: Color(0xFFE53935)),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  isProfile
                      ? _pickProfileImage(ImageSource.gallery)
                      : _pickCertificate(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.camera_alt, color: Color(0xFFE53935)),
                ),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  isProfile
                      ? _pickProfileImage(ImageSource.camera)
                      : _pickCertificate(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── EDIT PROFILE DIALOG ──
  void _showEditDialog() {
    final bloodController = TextEditingController(text: bloodGroup);
    final donorController = TextEditingController(text: donorType);

    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    String? selectedBlood = bloodGroups.contains(bloodGroup) ? bloodGroup : null;
    String? selectedDonor = donorType.isNotEmpty ? donorType : null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit, color: Color(0xFFE53935), size: 20),
              SizedBox(width: 8),
              Text('Edit Profile', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Blood Group Dropdown
              DropdownButtonFormField<String>(
                value: selectedBlood,
                decoration: InputDecoration(
                  labelText: 'Blood Group',
                  prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFFE53935)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                ),
                items: bloodGroups
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setDialog(() => selectedBlood = v),
              ),
              const SizedBox(height: 14),
              // Donor Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedDonor,
                decoration: InputDecoration(
                  labelText: 'Donor Type',
                  prefixIcon: const Icon(Icons.volunteer_activism, color: Color(0xFFE53935)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                ),
                items: ['Blood Donor', 'Organ Donor', 'Both', 'None']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setDialog(() => selectedDonor = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final uid = _auth.currentUser?.uid;
                if (uid == null) return;

                final newBlood = selectedBlood ?? bloodGroup;
                final newDonor = selectedDonor ?? donorType;

                await _firestore.collection('users').doc(uid).update({
                  'bloodGroup': newBlood,
                  'donorType': newDonor,
                });

                if (mounted) {
                  setState(() {
                    bloodGroup = newBlood;
                    donorType = newDonor;
                  });
                }

                Navigator.pop(ctx);
                _showSnackBar('Profile updated!', isSuccess: true);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── LOGOUT ──
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // ── SNACKBAR ──
  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── SHARE / UPDATE MY LOCATION ──
  // Saves the donor's current GPS coordinates so FindDonorScreen's
  // map can plot them and sort search results by real distance.
  Future<void> _updateLocation() async {
    setState(() => isUpdatingLocation = true);
    try {
      final pos = await LocationService.getCurrentPosition();
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore.collection('users').doc(uid).update({
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'locationUpdatedAt': Timestamp.now(),
      });

      if (mounted) {
        setState(() {
          latitude = pos.latitude;
          longitude = pos.longitude;
        });
        _showSnackBar('Location shared! Donors near you can find you now.',
            isSuccess: true);
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => isUpdatingLocation = false);
    }
  }

  // ── VIEW CERTIFICATE DIALOG ──
  void _viewCertificate() {
    if (certificateImageUrl.isEmpty) {
      _showSnackBar('No certificate uploaded yet');
      return;
    }
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Certificate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.network(
                certificateImageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = [house, road, area, city].where((s) => s.isNotEmpty).join(', ');

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE53935))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFEF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── HEADER CARD ──
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Top bar with title and actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'My Profile',
                              style: TextStyle(
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          // Edit button
                          IconButton(
                            onPressed: _showEditDialog,
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFFE53935)),
                            tooltip: 'Edit Profile',
                          ),
                          // Logout button
                          IconButton(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout, color: Colors.grey),
                            tooltip: 'Logout',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Profile avatar with upload indicator
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () => _showImageOptions(true),
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE53935), width: 3),
                              color: Colors.grey.shade100,
                            ),
                            child: isUploadingProfile
                                ? const Center(
                                    child: CircularProgressIndicator(color: Color(0xFFE53935)),
                                  )
                                : ClipOval(
                                    child: profileImageUrl.isNotEmpty
                                        ? Image.network(
                                            profileImageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.person, size: 60, color: Colors.grey),
                                          )
                                        : const Icon(Icons.person, size: 60, color: Colors.grey),
                                  ),
                          ),
                        ),
                        // Camera icon badge
                        GestureDetector(
                          onTap: () => _showImageOptions(true),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Name
                    Text(
                      fullName.isNotEmpty ? fullName : 'Your Name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Blood group badge
                    if (bloodGroup.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE53935).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bloodtype, size: 14, color: Color(0xFFE53935)),
                            const SizedBox(width: 4),
                            Text(
                              bloodGroup,
                              style: const TextStyle(
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Quick info row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _quickInfo(Icons.phone, 'Phone', phone.isNotEmpty ? phone : 'N/A'),
                          _verticalDivider(),
                          _quickInfo(Icons.person, 'Gender', gender.isNotEmpty ? gender : 'N/A'),
                          _verticalDivider(),
                          _quickInfo(Icons.cake, 'DOB', dob.isNotEmpty ? dob : 'N/A'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── INFO SECTIONS ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Contact Information
                    _sectionCard(
                      title: 'Contact Information',
                      icon: Icons.contact_page_outlined,
                      children: [
                        _detailRow(Icons.email_outlined, 'Email', email.isNotEmpty ? email : 'N/A'),
                        _detailRow(Icons.phone_outlined, 'Phone', phone.isNotEmpty ? phone : 'N/A'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Personal Details
                    _sectionCard(
                      title: 'Personal Details',
                      icon: Icons.person_outline,
                      children: [
                        _detailRow(Icons.wc_outlined, 'Gender', gender.isNotEmpty ? gender : 'N/A'),
                        _detailRow(Icons.cake_outlined, 'Date of Birth', dob.isNotEmpty ? dob : 'N/A'),
                        _detailRow(
                          Icons.location_on_outlined,
                          'Address',
                          address.isNotEmpty ? address : 'No address added',
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Donor Information
                    _sectionCard(
                      title: 'Donor Information',
                      icon: Icons.favorite_border,
                      trailing: GestureDetector(
                        onTap: _showEditDialog,
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      children: [
                        _detailRow(Icons.bloodtype_outlined, 'Blood Group',
                            bloodGroup.isNotEmpty ? bloodGroup : 'Not set'),
                        _detailRow(Icons.volunteer_activism_outlined, 'Donor Type',
                            donorType.isNotEmpty ? donorType : 'Not set'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // My Location — powers the free map in Find Donors
                    _sectionCard(
                      title: 'My Location',
                      icon: Icons.my_location_outlined,
                      children: [
                        _detailRow(
                          Icons.pin_drop_outlined,
                          'Status',
                          (latitude != null && longitude != null)
                              ? 'Shared — visible on the donor map'
                              : 'Not shared yet',
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE53935)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: isUpdatingLocation ? null : _updateLocation,
                            icon: isUpdatingLocation
                                ? const SizedBox(
                                    width: 16, height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.my_location, color: Color(0xFFE53935), size: 18),
                            label: Text(
                              (latitude != null)
                                  ? 'Update My Location'
                                  : 'Share My Location',
                              style: const TextStyle(color: Color(0xFFE53935)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Certificate Section
                    _sectionCard(
                      title: 'Donor Certificate',
                      icon: Icons.verified_outlined,
                      children: [
                        Row(
                          children: [
                            // Preview thumbnail
                            GestureDetector(
                              onTap: _viewCertificate,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: isUploadingCertificate
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFE53935),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : certificateImageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              certificateImageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.broken_image, color: Colors.grey),
                                            ),
                                          )
                                        : const Icon(Icons.image_outlined, color: Colors.grey, size: 32),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    certificateImageUrl.isNotEmpty
                                        ? 'Certificate uploaded'
                                        : 'No certificate yet',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: certificateImageUrl.isNotEmpty
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Upload your donor certificate for verification',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  // Upload button
                                  GestureDetector(
                                    onTap: () => _showImageOptions(false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE53935).withOpacity(0.3),
                                        ),
                                      ),
                                      child: const Text(
                                        'Upload / Replace',
                                        style: TextStyle(
                                          color: Color(0xFFE53935),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE53935)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Color(0xFFE53935)),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ── BOTTOM NAVIGATION ──
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        selectedItemColor: const Color(0xFFE53935),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              break;
            case 1:
              Navigator.pushReplacementNamed(context, AppRoutes.emergencyRequest);
              break;
            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.myRequest);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bloodtype_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  // ── HELPER WIDGETS ──

  Widget _quickInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE53935), size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE53935), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFFE53935)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}