import 'package:flutter/material.dart';
import 'package:grocery/provider/checklist_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final checkModel = Provider.of<CheckBoxModel>(context);
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
      body: ChangeNotifierProvider(
        create: (context) => CheckBoxModel(),
        child: SingleChildScrollView(
          child: ListTile(
            leading: Icon(Icons.food_bank, size: 40, color: Colors.yellow),
            title: Text("Food Item"),
            trailing: Checkbox(
              value: checkModel.isChecked,
              onChanged: (bool? newValue) {
                checkModel.toggle(newValue ?? false);
              },
            ),
          ),
        ),
      ),
    );
  }
}
