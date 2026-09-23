import 'dart:convert';

import 'package:expense_tracker/core/constants/storage_keys.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  String? get token => _prefs.getString(StorageKeys.token);

  String? get userJson => _prefs.getString(StorageKeys.user);

  bool get isOnboardingComplete =>
      _prefs.getBool(StorageKeys.onboardingComplete) ?? false;

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _prefs.setString(StorageKeys.token, token);
    await _prefs.setString(StorageKeys.user, jsonEncode(user));
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(StorageKeys.user, jsonEncode(user));
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(StorageKeys.onboardingComplete, true);
  }

  Future<void> clearSession() async {
    await _prefs.remove(StorageKeys.token);
    await _prefs.remove(StorageKeys.user);
  }

  Map<String, dynamic> readUserJson() {
    final raw = userJson;
    if (raw == null || raw.isEmpty) {
      throw const CacheException('No stored session');
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const CacheException('Invalid stored session');
  }
}
