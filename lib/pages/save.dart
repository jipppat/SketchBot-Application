import 'package:flutter/material.dart';

class SavePage extends StatelessWidget {
  const SavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Save',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 19, 31, 140),
        centerTitle: true,
      ),
    );
}
}