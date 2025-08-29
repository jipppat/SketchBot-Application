import 'package:flutter/material.dart';
import 'edit.dart';
import 'robot_page.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final Set<String> favorites;
  final Function(String url) onFavoriteToggle;

  const CategoryPage({
    super.key,
    required this.category,
    required this.favorites,
    required this.onFavoriteToggle,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<String> getImagesForCategory(String category) {
    switch (category) {
      case 'Cat':
        return [
          'assets/images/cat1.jpg',
          'assets/images/cat2.jpg',
          'assets/images/cat3.jpg',
          'assets/images/cat4.jpg'
        ];
      case 'Flowers':
        return [
          'assets/images/flower1.jpg',
          'assets/images/flower2.jpg',
          'assets/images/flower3.jpg',
          'assets/images/flower4.jpg'
        ];
      case 'Anime':
        return [
          'assets/images/anime1.jpg',
          'assets/images/Filo.jpg',
          'assets/images/Umemiya.jpg',
          'assets/images/Sakura.jpg'
        ];
      case 'Capybara':
        return [
          'assets/images/capybara cake.jpg',
          'assets/images/capybara mac.jpg',
          'assets/images/capybara pudding.jpg',
          
        ];
      case 'K-pop':
        return [
          'assets/images/kpop1.jpg',
          'assets/images/kpop2.jpg',
          'assets/images/kpop3.jpg'
        ];
      case 'Cake':
        return [
          'assets/images/cake1.jpg',
          'assets/images/cake2.jpg'
        ];
      default:
        return [];
    }
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
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
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
    final images = getImagesForCategory(widget.category);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.black,
      ),
      body: Padding(
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
                            onTap: () => showFullImagePopup(url),
                            child: Image.asset(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                          // ❤️ หัวใจมุมขวาบน
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                widget.onFavoriteToggle(url);
                                setState(() {});
                              },
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white,
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

                  // ชื่อไฟล์
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // ปุ่มแก้ไข + ปุ่ม Start
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color.fromARGB(255, 7, 74, 129)),
                          iconSize: 30,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditPage(imagePath: url),
                              ),
                            );
                          },
                          tooltip: 'Edit picture',
                        ),
                        IconButton(
  icon: const Icon(Icons.play_arrow, color: Colors.green),
  iconSize: 40,
  onPressed: () {
    // ไปหน้า RobotPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RobotPage()),
    );
  },
  tooltip: 'Start',
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
