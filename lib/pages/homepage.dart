import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'categorypage.dart';
import 'favorite.dart';
import 'profile.dart';
import 'save.dart';

class HomePage extends StatefulWidget {
  final List<String> favorites;
  final Function(String) onFavoriteToggle;
  final File? profileImage;
  final String? profileName;

  const HomePage({
    Key? key,
    required this.favorites,
    required this.onFavoriteToggle,
    this.profileImage,
    this.profileName,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  File? _selectedImage;

  late Set<String> favorites;
  late File? profileImage;
  late String profileName;

  @override
  void initState() {
    super.initState();
    favorites = widget.favorites.toSet();
    profileImage = widget.profileImage;
    profileName = widget.profileName ?? "Jirapat";
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

  final List<Map<String, dynamic>> categories = [
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
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 187, 12, 61),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Choose the right image and let us draw it for you.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "เลือกภาพที่ใช่ของคุณ แล้วเริ่มวาดไปด้วยกัน",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: pickImageFromGallery,
                  icon: const Icon(Icons.camera, size: 20, color: Colors.white),
                  label: const Text("Add from gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B4CB2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 206, 206, 212),
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

          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Category",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: categories.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(
                          category: category['title'],
                          favorites: favorites,
                          onFavoriteToggle: handleFavoriteToggle,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(category['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: const Color.fromARGB(196, 187, 12, 62),
                            child: Text(
                              category['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
      setState(() {
        _selectedImage = File(pickedFile.path);
        favorites.add(pickedFile.path);
      });

      widget.onFavoriteToggle(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildMainHomeContent(),
      FavoritePage(
        favorites: favorites.toList(),
        onFavoriteToggle: handleFavoriteToggle,
      ),
      const SavePage(),
      ProfilePage(
        onUpdate: (newImage, newName) {
          setState(() {
            profileImage = newImage;
            profileName = newName;
          });
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 19, 31, 140),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: profileImage != null
                  ? FileImage(profileImage!)
                  : const AssetImage('assets/images/self.jpg') as ImageProvider,
            ),
            const SizedBox(width: 12),
            Text(
              "Hello, $profileName!",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: currentIndex, children: pages),
      
    );
  }
}
