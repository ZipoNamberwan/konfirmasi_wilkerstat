import 'package:konfirmasi_wilkerstat/classes/services/third_party_api_service.dart';

class ThirdPartyProvider {
  static final ThirdPartyProvider _instance = ThirdPartyProvider._internal();
  factory ThirdPartyProvider() => _instance;

  ThirdPartyProvider._internal();

  late ThirdPartyApiService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = ThirdPartyApiService();
    await _dioService.init();
  }
}
