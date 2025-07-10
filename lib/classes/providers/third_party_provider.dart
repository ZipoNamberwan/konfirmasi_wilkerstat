import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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

  /// Get response from example.com with Accept: application/json header
  Future<Map<String, dynamic>> getGoogleDriveToken() async {
    final response = await _dioService.dio.get(
      'https://majapahit-api.majapahit.online/grup/',
      options: Options(headers: {'Accept': 'application/json'}),
    );

    return response.data as Map<String, dynamic>;
  }

  // https://sls-kendedes-1.pages.dev/api/k_qJvJZmkQgRDZLeId5gzw.json

  Future<List<Map<String, dynamic>>> getBusinessByVillageViaCloudflare(
    String encryptedVillageId,
  ) async {
    final response = await _dioService.dio.get(
      'https://sls-kendedes-1.pages.dev/api/$encryptedVillageId.json',
      options: Options(headers: {'Accept': 'application/json'}),
    );

    return response.data as List<Map<String, dynamic>>;
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
    // Read the file
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final fileBytes = await file.readAsBytes();
    final actualFileName = fileName ?? file.path.split('/').last;

    // Prepare metadata
    final metadata = <String, dynamic>{'name': actualFileName};

    if (folderId != null) {
      metadata['parents'] = [folderId];
    }

    // Create multipart form data
    final formData = FormData.fromMap({
      'metadata': MultipartFile.fromString(
        jsonEncode(metadata),
        filename: 'metadata.json',
        contentType: DioMediaType('application', 'json'),
      ),
      'media': MultipartFile.fromBytes(
        fileBytes,
        filename: actualFileName,
        contentType: DioMediaType('application', 'octet-stream'),
      ),
    });

    // Upload to Google Drive
    final response = await _dioService.dio.post(
      'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    return response.data as Map<String, dynamic>;
  }
}
