import 'package:konfirmasi_wilkerstat/classes/providers/version_checking_provider.dart';
import 'package:konfirmasi_wilkerstat/model/version.dart';

class VersionCheckingRepository {
  static final VersionCheckingRepository _instance =
      VersionCheckingRepository._internal();
  factory VersionCheckingRepository() => _instance;

  VersionCheckingRepository._internal();

  late VersionCheckingProvider _versionCheckingProvider;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _versionCheckingProvider = VersionCheckingProvider();
    await _versionCheckingProvider.init();
  }

  Future<Map<String, dynamic>> checkForUpdates(
    int currentVersion,
    String organizationId,
  ) async {
    final response = await _versionCheckingProvider.checkForUpdates(
      currentVersion,
      organizationId,
    );
    final Map<String, dynamic> versioningData = {
      'shouldUpdate': response['should_update'],
      'version': Version.fromJson(response['latest_version']),
      'assignments': response['assignments'],
    };
    return versioningData;
  }
}
