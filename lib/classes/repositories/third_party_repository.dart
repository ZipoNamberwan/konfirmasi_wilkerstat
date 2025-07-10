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

  /// Get Google Drive token from majapahit API
  Future<Map<String, dynamic>> getGoogleDriveToken() async {
    return await _thirdPartyProvider.getGoogleDriveToken();
  }

  /// Get business data by village via Cloudflare
  Future<List<Map<String, dynamic>>> getBusinessByVillageViaCloudflare(
    String encryptedVillageId,
  ) async {
    return await _thirdPartyProvider.getBusinessByVillageViaCloudflare(
      encryptedVillageId,
    );
  }

  /// Upload a file to Google Drive using their official API
  /// [token] - OAuth2 access token for Google Drive API
  /// [filePath] - Path to the file to upload
  /// [fileName] - Name of the file in Google Drive (optional, defaults to original filename)
  /// [folderId] - Google Drive folder ID to upload to (optional, uploads to root if not specified)
  Future<Map<String, dynamic>> uploadFileToGoogleDrive({
    required String token,
    required String filePath,
    String? fileName,
    String? folderId,
  }) async {
    return await _thirdPartyProvider.uploadFileToGoogleDrive(
      token: token,
      filePath: filePath,
      fileName: fileName,
      folderId: folderId,
    );
  }
}
