import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static final SharedPreferenceService _instance =
      SharedPreferenceService._internal();
  factory SharedPreferenceService() => _instance;

  SharedPreferenceService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _villagesKey = 'wilkerstat_villages';
  static const String _slsKey = 'wilkerstat_sls';

  late SharedPreferences prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Future<void> saveVillages(List<dynamic> villages) async {
    final List<Map<String, dynamic>> casted =
        villages.map((e) => Map<String, dynamic>.from(e)).toList();
    await prefs.setString(_villagesKey, jsonEncode(casted));
  }

  Future<void> saveSls(List<dynamic> sls) async {
    final List<Map<String, dynamic>> casted =
        sls.map((e) => Map<String, dynamic>.from(e)).toList();
    await prefs.setString(_slsKey, jsonEncode(casted));
  }

  String? getToken() {
    return prefs.getString(_tokenKey);
  }

  Map<String, dynamic>? getUser() {
    String? userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  List<Map<String, dynamic>> getVillages() {
    String? villagesJson = prefs.getString(_villagesKey);
    if (villagesJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(villagesJson));
    }
    return [];
  }

  List<Map<String, dynamic>> getSls() {
    String? slsJson = prefs.getString(_slsKey);
    if (slsJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(slsJson));
    }
    return [];
  }

  Future<void> clearToken() async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
