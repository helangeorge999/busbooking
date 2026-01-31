import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'edit_profile_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  String phone = '';
  String gender = '';
  String dob = '';
  String? photoUrl; // will hold server URL or local path

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// 🔹 Load profile from SharedPreferences first
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('user_name') ?? '';
      email = prefs.getString('user_email') ?? '';
      phone = prefs.getString('user_phone') ?? '';
      gender = prefs.getString('user_gender') ?? '';
      dob = prefs.getString('user_dob') ?? '';
      photoUrl = prefs.getString('photoUrl'); // load saved photo URL
    });

    final userId = prefs.getString('user_id');
    if (userId != null) {
      try {
        final res = await http.get(
          Uri.parse("http://10.0.2.2:5050/api/user/profile?userId=$userId"),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body)['data'];
          setState(() {
            name = data['name'] ?? name;
            email = data['email'] ?? email;
            phone = data['phone'] ?? phone;
            gender = data['gender'] ?? gender;
            dob = data['dob'] != null
                ? data['dob'].toString().split('T')[0]
                : dob;
            photoUrl = data['photoUrl'] ?? photoUrl;
          });

          // Update SharedPreferences with latest server data
          await prefs.setString('user_name', name);
          await prefs.setString('user_email', email);
          await prefs.setString('user_phone', phone);
          await prefs.setString('user_gender', gender);
          await prefs.setString('user_dob', dob);
          if (photoUrl != null) await prefs.setString('photoUrl', photoUrl!);
        }
      } catch (_) {
        // ignore server error, we already have local data
      }
    }
  }

  /// 🔹 Logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// PROFILE PHOTO
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.grey[300],
            backgroundImage: photoUrl != null
                ? (photoUrl!.startsWith('http')
                      ? NetworkImage(photoUrl!) as ImageProvider
                      : FileImage(File(photoUrl!)))
                : null,
            child: photoUrl == null
                ? const Icon(Icons.camera_alt, size: 30)
                : null,
          ),

          const SizedBox(height: 12),
          Text(
            name.isEmpty ? 'Your Name' : name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          /// INFO CARD
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                children: [
                  _infoTile(Icons.email, 'Email', email),
                  _infoTile(Icons.phone, 'Phone', phone),
                  _infoTile(Icons.person, 'Gender', gender),
                  _infoTile(Icons.cake, 'DOB', dob),
                  const SizedBox(height: 30),

                  /// EDIT PROFILE BUTTON
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      ).then((_) => _loadProfile());
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// LOGOUT BUTTON
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value.isEmpty ? '-' : value),
    );
  }
}
