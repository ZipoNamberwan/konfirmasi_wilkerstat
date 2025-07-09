import 'package:konfirmasi_wilkerstat/classes/providers/local_db/upload_db_provider.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:konfirmasi_wilkerstat/model/upload.dart';

class UploadDbRepository {
  static final UploadDbRepository _instance = UploadDbRepository._internal();
  factory UploadDbRepository() => _instance;

  UploadDbRepository._internal();

  late UploadDbProvider _provider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _provider = UploadDbProvider();
    await _provider.init();
  }

  // SlsUpload operations
  Future<void> saveSlsUpload(SlsUpload slsUpload) async {
    await _provider.saveSlsUpload(slsUpload.toJson());
  }

  Future<List<SlsUpload>> getSlsUploadBySlsId(String slsId) async {
    final List<Map<String, dynamic>> rawData = await _provider
        .getSlsUploadBySlsId(slsId);
    return rawData.map((map) => SlsUpload.fromJson(map)).toList();
  }

  // ImageUpload operations
  Future<void> saveImageUpload(ImageUpload imageUpload) async {
    final Map<String, dynamic> imageUploadData = {
      'id': imageUpload.id,
      'path': imageUpload.imagePath,
      'sls_id': imageUpload.slsId,
    };
    await _provider.saveImageUpload(imageUploadData);
  }

  Future<List<ImageUpload>> getImageUploadBySlsId(String slsId) async {
    final List<Map<String, dynamic>> rawData = await _provider
        .getImageUploadBySlsId(slsId);
    return rawData.map((map) => ImageUpload.fromMap(map)).toList();
  }

  // Get the latest/newest SLS upload for each SLS ID
  // Returns a Map where the key is slsId and value is the latest SlsUpload for that SLS
  // If an SLS has no uploads, its value will be null
  Future<Map<String, SlsUpload?>> getLatestSlsUploads(
    List<String> slsIds,
  ) async {
    final List<Map<String, dynamic>> rawData = await _provider
        .getLatestSlsUploads(slsIds);
    final Map<String, SlsUpload?> result = {};

    // Initialize all requested SLS IDs with null
    for (final slsId in slsIds) {
      result[slsId] = null;
    }

    // Fill in the actual uploads for SLS IDs that have them
    for (final map in rawData) {
      final slsUpload = SlsUpload.fromJson(map);
      result[slsUpload.sls.id] = slsUpload;
    }

    return result;
  }
}
