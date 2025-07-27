import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white)),
        actionsIconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              DateFormat('dd-MM-yyyy').format(DateTime.now()),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
