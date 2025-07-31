import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/uk_checklist/presentation/providers/uk_checklist_provider.dart';
import 'features/uk_checklist/presentation/screens/uk_checklist_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // UK Checklist provider
        ChangeNotifierProvider(create: (context) => UKChecklistProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UK Moving Checklist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade700,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const UKChecklistScreen(),
    );
  }
}
