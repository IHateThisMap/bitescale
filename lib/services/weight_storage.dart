import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/weight_entry.dart';

/// Persists weight entries on the device.
class WeightStorage {
  static const _key = 'weight_entries';

  Future<List<WeightEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final entries = list
        .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  Future<void> save(List<WeightEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
