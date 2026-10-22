import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Persists the [UserProfile] (height, goal, measurements...) on the device.
class ProfileStorage {
  static const _key = 'user_profile';

  Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const UserProfile();
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
