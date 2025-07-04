

import 'package:konfirmasi_wilkerstat/classes/services/dio_service.dart';
import 'package:konfirmasi_wilkerstat/classes/services/shared_preference_service.dart';

class AuthProvider {
  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;

  AuthProvider._internal();

  late SharedPreferenceService _sharedPreferenceService;
  late DioService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _sharedPreferenceService = SharedPreferenceService();
    await _sharedPreferenceService.init();
    _dioService = DioService();
    await _dioService.init();
  }

  bool isTokenExists() {
    return _sharedPreferenceService.getToken() != null &&
        _sharedPreferenceService.getUser() != null;
  }

  String? getToken() {
    return _sharedPreferenceService.getToken();
  }

  Map<String, dynamic>? getUser() {
    return _sharedPreferenceService.getUser();
  }

  List<Map<String, dynamic>> getVillages() {
    return _sharedPreferenceService.getVillages();
  }

  List<Map<String, dynamic>> getSls() {
    return _sharedPreferenceService.getSls();
  }

  Future<void> saveToken(String token) async {
    await _sharedPreferenceService.saveToken(token);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _sharedPreferenceService.saveUser(user);
  }

  Future<void> clearToken() async {
    await _sharedPreferenceService.clearToken();
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioService.dio.post(
      '/login/wilkerstat',
      data: {'email': email, 'password': password},
    );

    final data = response.data['data'];
    final token = data['token'];
    final user = data['user'];
    final villages = data['villages'];
    final sls = data['user']['wilkerstat_sls'];

    if (token != null) {
      await _sharedPreferenceService.saveToken(token);
      await _sharedPreferenceService.saveUser(user);
      await _sharedPreferenceService.saveVillages(villages);
      await _sharedPreferenceService.saveSls(sls);
    }

    return response.data;
  }

  Future<void> logout() async {
    await _dioService.dio.post('/logout');
    await _sharedPreferenceService.clearToken();
  }
}
