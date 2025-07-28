import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/grocery_list/presentation/providers/grocery_list_provider.dart';
import 'features/grocery_list/presentation/screens/grocery_list_screen.dart';
import 'core/constants/app_constants.dart';

// For backward compatibility with existing providers
import 'package:grocery/provider/checklist_provider.dart' as legacy;
import 'package:grocery/provider/expense_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // New refactored provider
        ChangeNotifierProvider(create: (context) => GroceryListProvider()),
        // Keep existing providers for backward compatibility
        ChangeNotifierProvider(create: (context) => legacy.CheckBoxModel()),
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
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
      title: 'Smart Grocery List',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const GroceryListScreen(),
    );
  }
}
