import 'package:flutter/material.dart';
import 'package:grocery/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExpenseProvider extends ChangeNotifier {
  final List<ExpenseRecord> _expenses = [];
  final List<ShoppingHistory> _history = [];

  static const String _expensesKey = 'expense_records';
  static const String _historyKey = 'shopping_history';

  List<ExpenseRecord> get expenses => _expenses;
  List<ShoppingHistory> get history => _history;

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  double get monthlyTotal {
    final now = DateTime.now();
    final thisMonth = _expenses.where(
      (expense) =>
          expense.date.year == now.year && expense.date.month == now.month,
    );
    return thisMonth.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final expense in _expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }
    return totals;
  }

  ExpenseProvider() {
    _loadFromPrefs();
  }

  Future<void> _saveExpensesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _expenses.map((expense) => expense.toJson()).toList();
    await prefs.setString(_expensesKey, json.encode(jsonList));
  }

  Future<void> _saveHistoryToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _history.map((history) => history.toJson()).toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Load expenses
    final expensesJson = prefs.getString(_expensesKey);
    if (expensesJson != null) {
      final List<dynamic> expensesList = json.decode(expensesJson);
      _expenses.clear();
      _expenses.addAll(
        expensesList.map((e) => ExpenseRecord.fromJson(e)).toList(),
      );
    }

    // Load history
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      final List<dynamic> historyList = json.decode(historyJson);
      _history.clear();
      _history.addAll(
        historyList.map((e) => ShoppingHistory.fromJson(e)).toList(),
      );
    }

    notifyListeners();
  }

  void addExpense(String title, double amount, String category) {
    final expense = ExpenseRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
    );
    _expenses.add(expense);
    _saveExpensesToPrefs();
    notifyListeners();
  }

  void addToHistory(List<TileItem> items, String storeName) {
    final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final history = ShoppingHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items
          .map(
            (item) => TileItem(
              title: item.title,
              isChecked: item.isChecked,
              price: item.price,
              quantity: item.quantity,
            ),
          )
          .toList(),
      date: DateTime.now(),
      totalAmount: totalAmount,
      storeName: storeName,
    );
    _history.insert(0, history); // Add to beginning
    _saveHistoryToPrefs();
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpensesToPrefs();
    notifyListeners();
  }

  void deleteHistory(String id) {
    _history.removeWhere((history) => history.id == id);
    _saveHistoryToPrefs();
    notifyListeners();
  }

  void restoreFromHistory(ShoppingHistory history) {
    // This will be used to restore a shopping list from history
    notifyListeners();
  }
}
