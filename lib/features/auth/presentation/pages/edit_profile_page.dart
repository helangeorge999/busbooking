import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final genderCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? photoUrl;
  String? userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    nameCtrl.text = prefs.getString('user_name') ?? '';
    emailCtrl.text = prefs.getString('user_email') ?? '';
    phoneCtrl.text = prefs.getString('user_phone') ?? '';
    genderCtrl.text = prefs.getString('user_gender') ?? '';
    dobCtrl.text = prefs.getString('user_dob') ?? '';

    photoUrl = prefs.getString('photoUrl');

    // 🔹 Use consistent key
    userId = prefs.getString('user_id');

    setState(() {});
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', nameCtrl.text);
    await prefs.setString('user_email', emailCtrl.text);
    await prefs.setString('user_phone', phoneCtrl.text);
    await prefs.setString('user_gender', genderCtrl.text);
    await prefs.setString('user_dob', dobCtrl.text);

    Navigator.pop(context);
  }

  /// PICK IMAGE FROM GALLERY
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await _uploadImage(_imageFile!);
    }
  }

  /// TAKE PHOTO USING CAMERA
  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await _uploadImage(_imageFile!);
    }
  }

  /// UPLOAD IMAGE TO BACKEND
  Future<void> _uploadImage(File image) async {
    if (userId == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:5050/api/user/upload-photo'),
    );
    request.fields['userId'] = userId!;
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['url'] != null) {
        // 🔹 Prepend host to relative path
        final fullUrl = 'http://10.0.2.2:5050/${data['url']}';
        setState(() => photoUrl = fullUrl);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('photoUrl', fullUrl);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to upload photo')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Server error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// PROFILE PHOTO
            CircleAvatar(
              radius: 50,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : (photoUrl != null
                        ? NetworkImage(photoUrl!) as ImageProvider
                        : null),
              child: photoUrl == null && _imageFile == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 10),

            /// GALLERY & CAMERA BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _field('Name', nameCtrl),
            _field('Email', emailCtrl),
            _field('Phone', phoneCtrl),
            _field('Gender', genderCtrl),
            _field('DOB', dobCtrl),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save Changes')),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
