import 'package:konfirmasi_wilkerstat/classes/providers/local_db/local_db_provider.dart';
import 'package:sqflite/sqflite.dart';

class UploadDbProvider {
  static final UploadDbProvider _instance = UploadDbProvider._internal();
  factory UploadDbProvider() => _instance;

  UploadDbProvider._internal();

  late LocalDbProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
  }

  Database get _db => _dbProvider.db;

  // SlsUpload operations - work with raw data
  Future<void> saveSlsUpload(Map<String, dynamic> slsUploadData) async {
    await _db.insert(
      'sls_upload',
      slsUploadData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getSlsUploadBySlsId(String slsId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'sls_upload',
      where: 'sls_id = ?',
      whereArgs: [slsId],
    );

    return maps;
  }

  // Get the latest/newest SLS upload for each SLS ID
  Future<List<Map<String, dynamic>>> getLatestSlsUploads(
    List<String> slsIds,
  ) async {
    if (slsIds.isEmpty) return [];

    // Create placeholders for the IN clause
    final placeholders = slsIds.map((e) => '?').join(',');

    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT su1.* FROM sls_upload su1
      INNER JOIN (
        SELECT sls_id, MAX(created_at) as max_created_at
        FROM sls_upload
        WHERE sls_id IN ($placeholders)
        GROUP BY sls_id
      ) su2 ON su1.sls_id = su2.sls_id AND su1.created_at = su2.max_created_at
      ORDER BY su1.created_at DESC
    ''', slsIds);

    return maps;
  }

  // ImageUpload operations - work with raw data
  Future<void> saveImageUpload(Map<String, dynamic> imageUploadData) async {
    await _db.insert(
      'image_upload',
      imageUploadData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getImageUploadBySlsId(String slsId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'image_upload',
      where: 'sls_id = ?',
      whereArgs: [slsId],
    );

    return maps;
  }
}
