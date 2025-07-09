import 'package:konfirmasi_wilkerstat/classes/providers/third_party_provider.dart';

class ThirdPartyRepository {
  static final ThirdPartyRepository _instance =
      ThirdPartyRepository._internal();
  factory ThirdPartyRepository() => _instance;

  ThirdPartyRepository._internal();

  late ThirdPartyProvider _thirdPartyProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _thirdPartyProvider = ThirdPartyProvider();
    await _thirdPartyProvider.init();
  }
}
