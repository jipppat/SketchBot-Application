import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'edit.dart';
import 'dart:io';
import 'robot_page.dart';
import 'homescaffold.dart'; 

class FavoritePage extends StatelessWidget {
  final List<String> favorites;
  final Function(String) onFavoriteToggle;

  const FavoritePage({
    Key? key,
    required this.favorites,
    required this.onFavoriteToggle,
  }) : super(key: key);

  void _editImage(BuildContext context, String imagePath) {
    if (imagePath.startsWith('assets/') || File(imagePath).existsSync()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditPage(imagePath: imagePath),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบไฟล์รูปภาพนี้')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScaffold()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Favorite Pictures',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 187, 12, 61),
          centerTitle: true,
        ),
        body: favorites.isEmpty
            ? const Center(child: Text('No favorites yet.'))
            : Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  itemCount: favorites.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final imagePath = favorites[index];
                    final fileName = imagePath.split('/').last;
                    final isFavorite = true; // อยู่หน้า Favorite

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // รูปภาพ + หัวใจมุมขวาบน
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (imagePath.startsWith('assets/') ||
                                          File(imagePath).existsSync()) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding:
                                                const EdgeInsets.all(10),
                                            child: InteractiveViewer(
                                              child: imagePath
                                                      .startsWith('assets/')
                                                  ? Image.asset(imagePath)
                                                  : Image.file(File(imagePath)),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: imagePath.startsWith('assets/')
                                        ? Image.asset(imagePath,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity)
                                        : (!kIsWeb &&
                                                File(imagePath).existsSync())
                                            ? Image.file(File(imagePath),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity)
                                            : const Center(
                                                child: Icon(Icons.broken_image,
                                                    color: Colors.red,
                                                    size: 40)),
                                  ),
                                  // ❤️ หัวใจมุมขวาบน
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => onFavoriteToggle(imagePath),
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            // ignore: dead_code
                                            : Icons.favorite_border,
                                        color: Colors.red,
                                        size: 28,
                                        shadows: const [
                                          Shadow(
                                              blurRadius: 3,
                                              color: Colors.black45,
                                              offset: Offset(1, 1))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // ชื่อไฟล์บรรทัดแรก
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            child: Text(
                              fileName,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          // ปุ่ม Edit + Start บรรทัดที่ 2
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 4, right: 4, bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  iconSize: 30,
                                  onPressed: () =>
                                      _editImage(context, imagePath),
                                  tooltip: 'Edit picture',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.play_arrow,
                                      color: Colors.black),
                                  iconSize: 40,
                                  tooltip: "Start",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RobotPage()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
