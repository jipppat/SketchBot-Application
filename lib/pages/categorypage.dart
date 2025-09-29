import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DefaultAssetBundle;
import 'edit.dart';
import 'robot_page.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final List<String> images; // ✅ รับทั้ง asset + gallery
  final Set<String> favorites;
  final Function(String url) onFavoriteToggle;

  const CategoryPage({
    super.key,
    required this.category,
    required this.images,
    required this.favorites,
    required this.onFavoriteToggle,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  /// ✅ ฟังก์ชันช่วย render รูป ไม่ว่าจะเป็น asset หรือ file
  Widget buildImage(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.startsWith("assets/")) {
      return Image.asset(
        path,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      return Image.file(
        File(path),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  /// ✅ copy asset → temp file
  Future<String> _prepareImagePath(BuildContext context, String url) async {
    if (url.startsWith("assets/")) {
      final byteData = await DefaultAssetBundle.of(context).load(url);
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/${url.split('/').last}');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      return tempFile.path;
    }
    return url; // ถ้าเป็นไฟล์จริง ใช้ตรง ๆ
  }

  void showFullImagePopup(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: buildImage(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: images.isEmpty
          ? const Center(child: Text("ยังไม่มีรูปในหมวดนี้"))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  final url = images[index];
                  final isFavorite = widget.favorites.contains(url);
                  final fileName = url.split('/').last;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => showFullImagePopup(url),
                                  child: buildImage(url),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.onFavoriteToggle(url);
                                      setState(() {});
                                    },
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? Colors.red
                                          : Colors.white,
                                      size: 28,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 3,
                                          color: Colors.black45,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          child: Text(
                            fileName,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 4, right: 4, bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color.fromARGB(255, 7, 74, 129)),
                                iconSize: 30,
                                onPressed: () async {
                                  final pathToSend =
                                      await _prepareImagePath(context, url);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditPage(imagePath: pathToSend),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.play_arrow,
                                    color: Colors.green),
                                iconSize: 40,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const RobotPage()),
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
    );
  }
}
