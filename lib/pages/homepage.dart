import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'categorypage.dart';
import 'favorite.dart';
import 'profile.dart';
import 'save.dart';

class HomePage extends StatefulWidget {
  final List<String> favorites;
  final Function(String) onFavoriteToggle;

  const HomePage({
    Key? key,
    required this.favorites,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  late Set<String> favorites;

  // เก็บรูปที่ผู้ใช้เพิ่ม แยกตาม Category
  Map<String, List<String>> categoryImages = {};

  // ✅ รูป default (asset) ของแต่ละหมวด
  final Map<String, List<String>> defaultAssets = {
    'Anime': [
      'assets/images/Frieren.jpg',
      'assets/images/Filo.jpg',
      'assets/images/Umemiya.jpg',
      'assets/images/Sakura.jpg',
    ],
    'Flowers': [
      'assets/images/flower1.jpg',
      'assets/images/flower2.jpg',
      'assets/images/flower3.jpg',
      'assets/images/flower4.jpg',
    ],
    'Cat': [
      'assets/images/cat1.jpg',
      'assets/images/cat2.jpg',
      'assets/images/cat3.jpg',
      'assets/images/cat4.jpg',
    ],
    'Capybara': [
      'assets/images/capybara cake.jpg',
      'assets/images/capybara mac.jpg',
      'assets/images/capybara pudding.jpg',
    ],
    'Cake': [
      'assets/images/cake1.jpg',
      'assets/images/cake2.jpg',
    ],
    'K-pop': [
      'assets/images/kpop1.jpg',
      'assets/images/kpop2.jpg',
      'assets/images/kpop3.jpg',
    ],
  };

  @override
  void initState() {
    super.initState();
    favorites = widget.favorites.toSet();
  }

  void handleFavoriteToggle(String url) {
    setState(() {
      if (favorites.contains(url)) {
        favorites.remove(url);
      } else {
        favorites.add(url);
      }
    });
    widget.onFavoriteToggle(url);
  }

  // รายชื่อหมวดหมู่ (มี My Self)
  final List<Map<String, dynamic>> categories = [
    {'title': 'My Self', 'image': 'assets/images/self.jpg'},
    {'title': 'Anime', 'image': 'assets/images/Anime.jpg'},
    {'title': 'Flowers', 'image': 'assets/images/Flower.jpg'},
    {'title': 'K-pop', 'image': 'assets/images/Kpop.jpg'},
    {'title': 'Cat', 'image': 'assets/images/Cat.jpg'},
    {'title': 'Capybara', 'image': 'assets/images/Capybara.jpg'},
    {'title': 'Cake', 'image': 'assets/images/Cake.jpg'},
  ];

  Widget _buildMainHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF13208C), Color(0xFF4055C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Choose the right image and let us draw it for you.\n\nเลือกภาพที่ใช่ของคุณ แล้วเริ่มวาดไปด้วยกัน",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.brush,
                    color: Colors.white.withOpacity(0.9), size: 50),
              ],
            ),
          ),

          // ปุ่ม Add Image + Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: pickImageFromGallery,
                  icon: const Icon(Icons.add_photo_alternate, size: 20),
                  label: const Text("Add Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13208C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Text(
              "Categories",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: categories.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryName = category['title'];

                // ✅ รวม asset + gallery (My Self = gallery only)
                final List<String> images = [
                  ...(categoryName == "My Self"
                      ? []
                      : (defaultAssets[categoryName] ?? [])),
                  ...(categoryImages[categoryName] ?? []),
                ];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(
                          category: categoryName,
                          favorites: favorites,
                          onFavoriteToggle: handleFavoriteToggle,
                          images: images,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.asset(
                            category['image'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          color: const Color.fromARGB(149, 38, 116, 212),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            categoryName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      // เลือก Category ที่จะเก็บ
      String? selectedCategory = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("เลือกหมวดหมู่"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: categories.map((cat) {
                return ListTile(
                  title: Text(cat['title']),
                  onTap: () => Navigator.pop(context, cat['title']),
                );
              }).toList(),
            ),
          );
        },
      );

      if (selectedCategory != null) {
        setState(() {
          categoryImages[selectedCategory] ??= [];
          categoryImages[selectedCategory]!.add(pickedFile.path);
        });

        widget.onFavoriteToggle(pickedFile.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final pages = [
      _buildMainHomeContent(),
      FavoritePage(
        favorites: favorites.toList(),
        onFavoriteToggle: handleFavoriteToggle,
      ),
      const SavePage(),
      const ProfilePage(), // ไปแก้ไขข้อมูลได้
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13208C),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("welcome");
            }
            final data = snapshot.data!;
            final name = data['name'] ?? "Guest";
            final imageUrl = data['imageUrl'];

            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl)
                      : const AssetImage('assets/images/self.jpg') as ImageProvider,
                ),
                const SizedBox(width: 12),
                Text(
                  "Hello, $name!",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            );
          },
        ),
      ),
      body: IndexedStack(index: currentIndex, children: pages),
    );
  }
}
