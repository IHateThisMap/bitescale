import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/food.dart';

/// Persists the saved foods and the food diary on the device.
class FoodStorage {
  static const _foodsKey = 'foods';
  static const _logKey = 'food_log';

  Future<List<Food>> loadFoods() async {
    final list = await _loadList(_foodsKey);
    return list.map(Food.fromJson).toList();
  }

  Future<void> saveFoods(List<Food> foods) =>
      _saveList(_foodsKey, foods.map((f) => f.toJson()));

  Future<List<FoodLogEntry>> loadLog() async {
    final list = await _loadList(_logKey);
    return list.map(FoodLogEntry.fromJson).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> saveLog(List<FoodLogEntry> log) =>
      _saveList(_logKey, log.map((e) => e.toJson()));

  /// Inserts or replaces [food] in the saved foods.
  Future<void> upsertFood(Food food) async {
    final foods = await loadFoods();
    final i = foods.indexWhere((f) => f.id == food.id);
    if (i == -1) {
      foods.add(food);
    } else {
      foods[i] = food;
    }
    await saveFoods(foods);
  }

  /// Removes a category the user created: its foods, and eaten foods
  /// logged with it, move to "Other". Returns how many saved foods moved.
  Future<int> removeCategory(String category) async {
    const fallback = 'Other';
    final foods = await loadFoods();
    final moved = foods.where((f) => f.category == category).length;
    await saveFoods([
      for (final f in foods)
        f.category == category ? f.withCategory(fallback) : f,
    ]);

    final log = await loadLog();
    await saveLog([
      for (final e in log)
        e.category == category ? e.copyWith(category: fallback) : e,
    ]);
    return moved;
  }

  Future<List<Map<String, dynamic>>> _loadList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> _saveList(String key, Iterable<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items.toList()));
  }
}
