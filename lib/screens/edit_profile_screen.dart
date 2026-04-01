import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/auth_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _supabase = Supabase.instance.client;
  File? _imageFile;
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = true;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase.from('users').select().eq('id', user.id).single();
      setState(() {
        _usernameController.text = response['username'];
        _bioController.text = response['bio'] ?? '';
        _currentAvatarUrl = response['avatar_url'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _saveChanges() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? avatarUrl = _currentAvatarUrl;

      if (_imageFile != null) {
        final filePath = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _supabase.storage.from('avatars').upload(filePath, _imageFile!);
        avatarUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      }

      await _supabase.from('users').update({
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'avatar_url': avatarUrl,
      }).eq('id', user.id);

      Get.back();
      Get.snackbar('Success', 'Profile Updated!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white10,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_currentAvatarUrl != null ? NetworkImage(_currentAvatarUrl!) : null) as ImageProvider?,
                      child: _imageFile == null && _currentAvatarUrl == null
                          ? const Icon(Icons.add_a_photo, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Change Photo', style: GoogleFonts.outfit(color: Colors.white54)),
                  const SizedBox(height: 40),
                  _buildTextField('Username', _usernameController),
                  const SizedBox(height: 20),
                  _buildTextField('Bio', _bioController, maxLines: 3),
                  const SizedBox(height: 60),
                  _buildSaveButton(),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => _confirmDelete(),
                    child: Text(
                      'Delete Account & Data',
                      style: GoogleFonts.outfit(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE94057),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('Save Changes', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: 'Danger Zone',
      middleText: 'Are you sure? This delete all your data permanently.',
      backgroundColor: const Color(0xFF1E1E2C),
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.find<AuthController>().deleteAccount(),
    );
  }
}
