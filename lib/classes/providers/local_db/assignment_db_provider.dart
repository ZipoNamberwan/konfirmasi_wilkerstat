import 'package:konfirmasi_wilkerstat/classes/providers/local_db/local_db_provider.dart';
import 'package:sqflite/sqflite.dart';

class AssignmentDbProvider {
  static final AssignmentDbProvider _instance =
      AssignmentDbProvider._internal();
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
        'has_downloaded': (sl['hasDownloaded'] ?? false) ? 1 : 0,
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

  Future<List<Map<String, dynamic>>> getActiveVillages() async {
    return await _dbProvider.db.query(
      'village',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getActiveSls() async {
    return await _dbProvider.db.query(
      'sls',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );
  }

  Future<void> markVillagesAsDeleted(List<String> villageIds) async {
    final batch = _dbProvider.db.batch();

    for (final id in villageIds) {
      batch.update(
        'village',
        {'is_deleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> reactivateVillages(List<String> villageIds) async {
    final batch = _dbProvider.db.batch();

    for (final id in villageIds) {
      batch.update(
        'village',
        {'is_deleted': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> markSlsAsDeleted(List<String> slsIds) async {
    final batch = _dbProvider.db.batch();
    for (final id in slsIds) {
      batch.update('sls', {'is_deleted': 1}, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> reactivateSls(List<String> slsIds) async {
    final batch = _dbProvider.db.batch();
    for (final id in slsIds) {
      batch.update('sls', {'is_deleted': 0}, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateVillageDownloadStatus(
    String villageId,
    bool hasDownloaded,
  ) async {
    final batch = _dbProvider.db.batch();

    // Update the village's hasDownloaded status
    batch.update(
      'village',
      {'has_downloaded': hasDownloaded ? 1 : 0},
      where: 'id = ?',
      whereArgs: [villageId],
    );

    // If village is marked as downloaded, also mark all its SLS as downloaded
    if (hasDownloaded) {
      batch.update(
        'sls',
        {'has_downloaded': 1},
        where: 'village_id = ?',
        whereArgs: [villageId],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> updateSlsDownloadStatus(String slsId, bool hasDownloaded) async {
    await _dbProvider.db.update(
      'sls',
      {'has_downloaded': hasDownloaded ? 1 : 0},
      where: 'id = ?',
      whereArgs: [slsId],
    );
  }

  Future<void> saveBusinesses(List<Map<String, dynamic>> businesses) async {
    final batch = _dbProvider.db.batch();

    for (final business in businesses) {
      batch.insert('business', {
        'id': business['id'],
        'name': business['name'],
        'owner': business['owner'],
        'address': business['address'],
        'sls_id': business['sls_id'],
        'status': business['status'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getBusinessesBySls(String slsId) async {
    return await _dbProvider.db.query(
      'business',
      where: 'sls_id = ?',
      whereArgs: [slsId],
    );
  }

  Future<void> updateBusinessStatus(String businessId, String status) async {
    await _dbProvider.db.update(
      'business',
      {'status': status},
      where: 'id = ?',
      whereArgs: [businessId],
    );
  }

  Future<Map<String, dynamic>> getSlsById(String slsId) async {
    final List<Map<String, dynamic>> result = await _dbProvider.db.query(
      'sls',
      where: 'id = ?',
      whereArgs: [slsId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('SLS with id $slsId not found');
    }
  }
}
