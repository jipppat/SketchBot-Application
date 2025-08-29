import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final Function(File?, String) onUpdate;

  const ProfilePage({super.key, required this.onUpdate});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController(text: "Your Name");
  final _emailController = TextEditingController(text: "you@example.com");
  final _dobController = TextEditingController(text: "1990-01-01");
  String? _imagePath;
  bool _isSaving = false; // สถานะโหลด

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
    }
  }

  Widget _buildProfileImage() {
    if (_imagePath == null) {
      return const CircleAvatar(
        radius: 55,
        backgroundImage: AssetImage('assets/images/default_profile.png'),
      );
    } else if (kIsWeb) {
      return CircleAvatar(
        radius: 55,
        backgroundImage: NetworkImage(_imagePath!),
      );
    } else {
      return CircleAvatar(
        radius: 55,
        backgroundImage: FileImage(File(_imagePath!)),
      );
    }
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
                    Color.fromARGB(255, 187, 12, 61),
                    Color.fromARGB(255, 240, 64, 90),
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
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _buildProfileImage(),
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: Icon(Icons.camera_alt,
                              size: 20, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameController.text,
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
                            decoration:
                                _inputDecoration('Date of Birth', Icons.cake),
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate:
                                    DateTime.tryParse(_dobController.text) ??
                                        DateTime(1990),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                _dobController.text = pickedDate
                                    .toIso8601String()
                                    .split('T')
                                    .first;
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            decoration:
                                _inputDecoration('Email', Icons.email),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              setState(() {
                                _isSaving = true;
                              });

                              // จำลองเวลาในการบันทึกข้อมูล
                              await Future.delayed(const Duration(seconds: 1));

                              File? imageFile;
                              if (_imagePath != null && !kIsWeb) {
                                imageFile = File(_imagePath!);
                              }
                              widget.onUpdate(imageFile, _nameController.text);

                              setState(() {
                                _isSaving = false;
                              });

                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 187, 12, 61),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
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
