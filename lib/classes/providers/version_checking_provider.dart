import 'package:konfirmasi_wilkerstat/classes/services/dio_service.dart';

class VersionCheckingProvider {
  static final VersionCheckingProvider _instance =
      VersionCheckingProvider._internal();
  factory VersionCheckingProvider() => _instance;

  VersionCheckingProvider._internal();

  late DioService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
  }

  Future<Map<String, dynamic>> checkForUpdates(
    int currentVersion,
    String organizationId,
  ) async {
    final response = await _dioService.dio.get(
      '/version/check/leres-pak',
      queryParameters: {
        'version': currentVersion,
        'organization': organizationId,
      },
    );
    return response.data['data'];
  }
}
