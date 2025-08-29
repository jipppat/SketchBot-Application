import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite.dart';
import 'homepage.dart';
import 'save.dart';
import 'profile.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int currentIndex = 0;
  List<String> favorites = [];

  File? profileImage;
  String profileName = "Hello!,  ";

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites);
  }

  void toggleFavorite(String url) {
    setState(() {
      if (favorites.contains(url)) {
        favorites.remove(url);
      } else {
        favorites.add(url);
      }
    });
    _saveFavorites();
  }

  void updateProfile(File? newImage, String newName) {
    setState(() {
      profileImage = newImage;
      profileName = newName;
    });
  }

  List<Widget> get pages => [
        HomePage(
          favorites: favorites,
          onFavoriteToggle: toggleFavorite,
          profileImage: profileImage,
          profileName: profileName,
        ),
        FavoritePage(
          favorites: favorites,
          onFavoriteToggle: toggleFavorite,
        ),
        const SavePage(),
        ProfilePage(
          onUpdate: updateProfile,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Save'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
