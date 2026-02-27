import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api_config.dart';
import '../../../../core/services/hive/hive_service.dart';
import '../../../../main.dart';

import 'edit_profile_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static String get _base => '${ApiConfig.userUrl}';

  String name = '';
  String email = '';
  String phone = '';
  String gender = '';
  String dob = '';
  String? photoUrl;
  bool _uploadingPhoto = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ── Load profile ───────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    final token = prefs.getString('token') ?? '';

    // Show cached data instantly while fetching
    setState(() {
      name = prefs.getString('user_name') ?? '';
      email = prefs.getString('user_email') ?? '';
      phone = prefs.getString('user_phone') ?? '';
      gender = prefs.getString('user_gender') ?? '';
      dob = prefs.getString('user_dob') ?? '';
      photoUrl = prefs.getString('photoUrl');
    });

    if (userId.isEmpty) return;

    try {
      final res = await http.get(
        Uri.parse('$_base/profile?userId=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;

        String? fetchedPhoto;
        final p = data['photoUrl'] as String? ?? '';
        if (p.isNotEmpty) {
          fetchedPhoto = ApiConfig.fixImageUrl(p);
        }

        setState(() {
          name = data['name'] ?? name;
          email = data['email'] ?? email;
          phone = data['phone'] ?? phone;
          gender = data['gender'] ?? gender;
          dob = (data['dob'] ?? dob).toString().split('T')[0];
          if (fetchedPhoto != null) photoUrl = fetchedPhoto;
        });

        // Update both SharedPreferences and Hive cache
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', email);
        await prefs.setString('user_phone', phone);
        await prefs.setString('user_gender', gender);
        await prefs.setString('user_dob', dob);
        if (photoUrl != null) await prefs.setString('photoUrl', photoUrl!);
        await HiveService.cacheProfile({
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
          'dob': dob,
          'photoUrl': photoUrl ?? '',
        });
      }
    } catch (e) {
      // Fallback to Hive cache when offline
      final cached = HiveService.getCachedProfile();
      if (cached != null) {
        setState(() {
          name = cached['name'] ?? name;
          email = cached['email'] ?? email;
          phone = cached['phone'] ?? phone;
          gender = cached['gender'] ?? gender;
          dob = (cached['dob'] ?? dob).toString().split('T')[0];
          final cachedPhoto = cached['photoUrl'] as String? ?? '';
          if (cachedPhoto.isNotEmpty) photoUrl = cachedPhoto;
        });
      }
      debugPrint('Profile fetch error: $e');
    }
  }

  // ── Pick image — show gallery/camera choice ────────────────────────────────
  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Update Profile Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF1565C0),
                  ),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Pick an existing photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.teal,
                  ),
                ),
                title: const Text('Take a Photo'),
                subtitle: const Text('Use your camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (picked == null) return;
    await _uploadPhoto(File(picked.path));
  }

  // ── Upload photo → POST /api/user/upload-photo ─────────────────────────────
  Future<void> _uploadPhoto(File imageFile) async {
    setState(() => _uploadingPhoto = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final token = prefs.getString('token') ?? '';

      if (userId.isEmpty) {
        _snack('Session expired. Please login again.', Colors.red);
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_base/upload-photo'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['userId'] = userId;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      debugPrint('=== UPLOAD DEBUG ===');
      debugPrint('URL: $_base/upload-photo');
      debugPrint('UserId: $userId');
      debugPrint('Token: ${token.substring(0, 20)}...');
      debugPrint('File: ${imageFile.path}');
      debugPrint('====================');

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final res = await http.Response.fromStream(streamed);
      debugPrint('Response status: ${res.statusCode}');
      debugPrint('Response body: ${res.body}');
      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 && body['success'] == true) {
        // Backend returns full URL — fix for current device
        final String rawUrl = body['url'] as String;
        final String newUrl = ApiConfig.fixImageUrl(rawUrl);

        setState(() => photoUrl = newUrl);
        await prefs.setString('photoUrl', newUrl);
        _snack('Profile photo updated!', Colors.green);
      } else {
        _snack(body['message'] ?? 'Upload failed. Try again.', Colors.red);
      }
    } catch (e, stackTrace) {
      _snack('Network error: $e', Colors.red);
      debugPrint('=== UPLOAD ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('====================');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  ImageProvider? _photoProvider() {
    if (photoUrl == null || photoUrl!.isEmpty) return null;
    if (photoUrl!.startsWith('http')) return NetworkImage(photoUrl!);
    try {
      if (File(photoUrl!).existsSync()) return FileImage(File(photoUrl!));
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: const Color(0xFF1565C0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ── Gradient header ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 114,
                          height: 114,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _photoProvider() != null
                                ? Image(
                                    image: _photoProvider()!,
                                    fit: BoxFit.cover,
                                    width: 110,
                                    height: 110,
                                  )
                                : Container(
                                    color: Colors.grey[100],
                                    child: Center(
                                      child: name.isNotEmpty
                                          ? Text(
                                              name[0].toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1565C0),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 44,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                          ),
                        ),
                        if (_uploadingPhoto)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.45),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          ),
                        if (!_uploadingPhoto)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: _pickPhoto,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF1565C0),
                                  size: 17,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name.isEmpty ? 'Your Name' : name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _uploadingPhoto ? null : _pickPhoto,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _uploadingPhoto ? 'Uploading…' : 'Change Photo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Info section ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _infoRow(Icons.email_outlined, 'Email', email),
                          _divider(),
                          _infoRow(Icons.phone_outlined, 'Phone', phone),
                          _divider(),
                          _infoRow(Icons.person_outline, 'Gender', gender),
                          _divider(),
                          _infoRow(
                            Icons.cake_outlined,
                            'Date of Birth',
                            dob.isEmpty ? '—' : dob,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        ).then((_) async {
                          await _loadProfile();
                          appProvider.notify();
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 18,
                        ),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: _logout,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 52, endIndent: 16);

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF1565C0), size: 20),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    ),
  );
}
