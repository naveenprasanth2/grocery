import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/grocery_template.dart';
import '../../domain/entities/grocery_history.dart';

class GroceryStorageService {
  static const _templatesKey = 'grocery_templates';
  static const _historyKey = 'grocery_history';
  GroceryStorageService._();
  static final instance = GroceryStorageService._();

  Future<List<GroceryTemplate>> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_templatesKey);
    if (jsonStr == null) return [];
    final list = json.decode(jsonStr) as List;
    return list.map((e) => GroceryTemplate.fromJson(e)).toList();
  }

  Future<void> saveTemplate(GroceryTemplate template) async {
    final templates = await loadTemplates();
    final idx = templates.indexWhere((t) => t.id == template.id);
    if (idx >= 0) {
      templates[idx] = template;
    } else {
      templates.add(template);
    }
    await _saveTemplatesList(templates);
  }

  Future<void> deleteTemplate(String id) async {
    final templates = await loadTemplates();
    templates.removeWhere((t) => t.id == id);
    await _saveTemplatesList(templates);
  }

  Future<void> _saveTemplatesList(List<GroceryTemplate> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(templates.map((e) => e.toJson()).toList());
    await prefs.setString(_templatesKey, jsonStr);
  }

  Future<List<GroceryHistory>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_historyKey);
    if (jsonStr == null) return [];
    final list = json.decode(jsonStr) as List;
    return list.map((e) => GroceryHistory.fromJson(e)).toList();
  }

  Future<void> saveHistory(GroceryHistory history) async {
    final histories = await loadHistory();
    final idx = histories.indexWhere((h) => h.id == history.id);
    if (idx >= 0) {
      histories[idx] = history;
    } else {
      histories.add(history);
    }
    await _saveHistoryList(histories);
  }

  Future<void> deleteHistory(String id) async {
    final histories = await loadHistory();
    histories.removeWhere((h) => h.id == id);
    await _saveHistoryList(histories);
  }

  Future<void> _saveHistoryList(List<GroceryHistory> histories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(histories.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, jsonStr);
  }
}
