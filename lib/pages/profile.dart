import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String _email = "";

  File? _imageFile;
  String? _imageUrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _email = user.email ?? "";
    });

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        _nameController.text = doc['name'] ?? "No name";
        _dobController.text = doc['dob'] ?? "1990-01-01";
        _imageUrl = doc['imageUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    String? imageUrl = _imageUrl;
    if (_imageFile != null) {
      final ref = FirebaseStorage.instance.ref().child('profiles/$uid.jpg');
      await ref.putFile(_imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      "name": _nameController.text,
      "dob": _dobController.text,
      "email": _email,
      "imageUrl": imageUrl,
    }, SetOptions(merge: true));

    setState(() {
      _isSaving = false;
      _imageUrl = imageUrl;
    });

    // ✅ ส่งค่ากลับไปหน้า HomePage
    Navigator.pop(context, {
      "name": _nameController.text,
      "dob": _dobController.text,
      "email": _email,
      "imageUrl": imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully ✅")),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // 🔹 AuthWrapper จะ redirect ไป LoginPage เอง
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 19, 31, 140)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 19, 31, 140),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,color:Color.fromARGB(255, 255, 255, 255),), // 🔹 ปุ่ม Logout
            onPressed: _logout,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 19, 31, 140),
                    Color.fromARGB(255, 96, 107, 211),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_imageUrl != null
                              ? NetworkImage(_imageUrl!)
                              : const AssetImage('assets/images/default_profile.png'))
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameController.text.isNotEmpty ? _nameController.text : "Your Name",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: _inputDecoration('Name', Icons.person),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _dobController,
                            readOnly: true,
                            decoration: _inputDecoration('Date of Birth', Icons.cake),
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.tryParse(_dobController.text) ?? DateTime(1990),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                _dobController.text = pickedDate.toIso8601String().split('T').first;
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            readOnly: true,
                            decoration: _inputDecoration('Email', Icons.email).copyWith(
                              hintText: _email,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 19, 31, 140),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
