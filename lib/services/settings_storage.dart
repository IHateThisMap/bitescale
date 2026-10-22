import 'package:shared_preferences/shared_preferences.dart';

/// App-wide settings.
class SettingsStorage {
  static const _languageKey = 'language';
  static const _graphRangeKey = 'weight_graph_range_days';

  /// How many days the weight graph shows, or null for the longest range
  /// available (which grows as more weights are recorded).
  Future<int?> loadGraphRangeDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_graphRangeKey);
  }

  Future<void> saveGraphRangeDays(int? days) async {
    final prefs = await SharedPreferences.getInstance();
    if (days == null) {
      await prefs.remove(_graphRangeKey);
    } else {
      await prefs.setInt(_graphRangeKey, days);
    }
  }

  /// Language code such as 'fi', or null to follow the phone's language.
  Future<String?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  Future<void> saveLanguage(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_languageKey);
    } else {
      await prefs.setString(_languageKey, code);
    }
  }
}
