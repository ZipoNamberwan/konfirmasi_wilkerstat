import 'package:konfirmasi_wilkerstat/classes/providers/auth_provider.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/model/user.dart';
import 'package:konfirmasi_wilkerstat/model/village.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  AuthRepository._internal();

  late AuthProvider _authProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _authProvider = AuthProvider();
    await _authProvider.init();
  }

  bool isTokenExists() {
    return _authProvider.isTokenExists();
  }

  String? getToken() {
    return _authProvider.getToken();
  }

  User? getUser() {
    final userJson = _authProvider.getUser();
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return null;
  }

  List<Village> getVillages() {
    final villagesJson = _authProvider.getVillages();
    return villagesJson.map((village) => Village.fromJson(village)).toList();
  }

  List<Sls> getSls() {
    final slsJson =
        _authProvider.getSls(); // returns List<Map<String, dynamic>>
    final villages = getVillages(); // already implemented
    final Map<String, Village> villageMap = {for (var v in villages) v.id: v};

    return slsJson.map((json) {
      final villageId = json['village_id'] as String;

      return Sls(
        id: json['id'].toString(),
        code: json['short_code'] as String,
        name: json['name'] as String,
        isAdded: false,
        village: villageMap[villageId]!,
      );
    }).toList();
  }

  Future<void> clearToken() async {
    await _authProvider.clearToken();
  }

  Future<User> login({required String email, required String password}) async {
    final response = await _authProvider.login(
      email: email,
      password: password,
    );

    return User.fromJson(response['data']['user']);
  }

  Future<void> logout() async {
    await _authProvider.logout();
  }
}
