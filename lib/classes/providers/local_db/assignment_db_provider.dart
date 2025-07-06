import 'package:konfirmasi_wilkerstat/classes/providers/local_db/local_db_provider.dart';
import 'package:sqflite/sqflite.dart';

class AssignmentDbProvider {
  static final AssignmentDbProvider _instance = AssignmentDbProvider._internal();
  factory AssignmentDbProvider() => _instance;

  AssignmentDbProvider._internal();

  late LocalDbProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
  }

  Future<void> saveVillages(List<Map<String, dynamic>> villages) async {
    // Optional: Use a batch for better performance
    final batch = _dbProvider.db.batch();

    for (final village in villages) {
      batch.insert('village', {
        'id': village['id'],
        'short_code': village['short_code'],
        'name': village['name'],
        'has_downloaded': (village['hasDownloaded'] ?? false) ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<void> saveSls(List<Map<String, dynamic>> sls) async {
    // Optional: Use a batch for better performance
    final batch = _dbProvider.db.batch();

    for (final sl in sls) {
      batch.insert('sls', {
        'id': sl['id'],
        'short_code': sl['short_code'],
        'name': sl['name'],
        'village_id': sl['village_id'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getVillages() async {
    return await _dbProvider.db.query('village');
  }

  Future<List<Map<String, dynamic>>> getSls() async {
    return await _dbProvider.db.query('sls');
  }
}
