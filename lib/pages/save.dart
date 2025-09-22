import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  List<File> savedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/sketches');
    if (await folder.exists()) {
      setState(() {
        savedFiles = folder.listSync().map((f) => File(f.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Data")),
      body: savedFiles.isEmpty
          ? const Center(child: Text("ยังไม่มีข้อมูลที่บันทึก"))
          : ListView.builder(
              itemCount: savedFiles.length,
              itemBuilder: (context, index) {
                final file = savedFiles[index];
                return ListTile(
                  title: Text(file.path.split("/").last),
                  subtitle: Text(file.readAsStringSync()),
                );
              },
            ),
    );
  }
}
