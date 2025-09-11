import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'robot_page.dart';

class EditPage extends StatefulWidget {
  final String imagePath;

  const EditPage({super.key, required this.imagePath});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late String currentImagePath;
  Uint8List? currentImageBytes; // สำหรับ Web
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    currentImagePath = widget.imagePath;
  }

  Future<void> removeBackground() async {
    try {
      setState(() {
        isProcessing = true;
      });

      String imagePathToSend = currentImagePath;

      // ✅ ถ้าเป็น assets ให้ copy ไป temp ก่อน
      if (currentImagePath.startsWith('assets/') && !kIsWeb) {
        final byteData = await rootBundle.load(currentImagePath);
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp.png');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        imagePathToSend = tempFile.path;
      }

      print("➡️ Sending file: $imagePathToSend");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://bg-remover-api-fksm.onrender.com/remove-bg'),

      
      );

      if (kIsWeb) {
        // บน Web ต้องโหลด bytes จาก asset/imagePath
        final byteData = await rootBundle.load(imagePathToSend);
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          byteData.buffer.asUint8List(),
          filename: "upload.png",
        ));
      } else {
        request.files
            .add(await http.MultipartFile.fromPath('file', imagePathToSend));
      }

      var response = await request.send();
      print("📡 Status: ${response.statusCode} ${response.reasonPhrase}");

      final respBytes = await response.stream.toBytes();

      if (response.statusCode == 200) {
        if (kIsWeb) {
          // 🌐 บน Web แสดงด้วย memory
          setState(() {
            currentImageBytes = respBytes;
          });
        } else {
          // 📱 Mobile/Desktop เซฟไฟล์ลง temp
          final tempDir = await getTemporaryDirectory();
          final uniqueName = const Uuid().v4();
          final newFile = File('${tempDir.path}/removed_bg_$uniqueName.png');
          await newFile.writeAsBytes(respBytes);

          setState(() {
            currentImagePath = newFile.path;
            currentImageBytes = null;
          });
        }
      } else {
        print("❌ Error: ${String.fromCharCodes(respBytes)}");
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
      print("🔥 Exception: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<File> convertToSketch(String path) async {
    String realPath = path;
    if (path.startsWith('assets/') && !kIsWeb) {
      final byteData = await rootBundle.load(path);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/asset_copy.png');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      realPath = tempFile.path;
    }

    final bytes = await File(realPath).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return File(realPath);

    img.Image grayscale = img.grayscale(image);
    img.Image edges = img.sobel(grayscale);
    img.Image inverted = img.invert(edges);
    img.Image finalSketch = img.adjustColor(inverted, contrast: 150);

    final tempDir = await getTemporaryDirectory();
    final sketchFile = File('${tempDir.path}/sketch_${const Uuid().v4()}.png');
    await sketchFile.writeAsBytes(img.encodePng(finalSketch));

    return sketchFile;
  }

  @override
  Widget build(BuildContext context) {
    final isAsset = currentImagePath.startsWith('assets/');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Image'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.black),
            iconSize: 40,
            tooltip: "Start",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RobotPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: currentImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(currentImageBytes!,
                          fit: BoxFit.contain),
                    )
                  : isAsset
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(currentImagePath,
                              fit: BoxFit.contain),
                        )
                      : File(currentImagePath).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(File(currentImagePath),
                                  fit: BoxFit.contain),
                            )
                          : const Text('ไม่พบไฟล์รูปภาพ'),
            ),
          ),
          if (isProcessing)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _editIconButton(
                  icon: Icons.remove_circle_outline,
                  label: 'Remove background',
                  textColor: Colors.black,
                  onTap: removeBackground,
                ),
                _editIconButton(
                  icon: Icons.visibility_outlined,
                  label: 'Preview Line Art',
                  textColor: Colors.black,
                  backgroundColor: Colors.white,
                  onTap: () async {
                    if (kIsWeb) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("ยังไม่รองรับ Preview Line Art บน Web")),
                      );
                      return;
                    }
                    File sketchFile =
                        await convertToSketch(currentImagePath);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          insetPadding: const EdgeInsets.all(10),
                          backgroundColor: Colors.black,
                          child: InteractiveViewer(
                            child: Image.file(sketchFile),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: backgroundColor,
            foregroundColor: Colors.black,
            radius: 28,
            child: Icon(icon, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(fontSize: 13, color: textColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
