import 'package:konfirmasi_wilkerstat/classes/providers/local_db/assignment_db_provider.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/model/village.dart';

class AssignmentDbRepository {
  static final AssignmentDbRepository _instance =
      AssignmentDbRepository._internal();
  factory AssignmentDbRepository() => _instance;

  AssignmentDbRepository._internal();

  late AssignmentDbProvider _provider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _provider = AssignmentDbProvider();
    await _provider.init();
  }

  Future<void> saveVillages(List<Village> villages) async {
    final villagesJson = villages.map((village) => village.toJson()).toList();
    await _provider.saveVillages(villagesJson);
  }

  Future<void> saveSls(List<Sls> sls) async {
    final slsJson = sls.map((sl) => sl.toJson()).toList();
    await _provider.saveSls(slsJson);
  }

  Future<List<Village>> getVillages() async {
    final villagesJson = await _provider.getVillages();
    return villagesJson.map((village) => Village.fromJson(village)).toList();
  }

  Future<List<Sls>> getSls() async {
    final slsJson = await _provider.getSls();
    final villages = await getVillages();
    final Map<String, Village> villageMap = {for (var v in villages) v.id: v};

    return slsJson.map((json) {
      final villageId = json['village_id'] as String;

      return Sls(
        id: json['id'].toString(),
        code: json['short_code'] as String,
        name: json['name'] as String,
        village: villageMap[villageId]!,
        isDeleted:
            json['is_deleted'] == 1, // Assuming is_deleted is stored as INTEGER
        hasDownloaded:
            json['has_downloaded'] == 1, // Assuming has_downloaded is INTEGER
      );
    }).toList();
  }

  Future<List<Village>> getActiveVillages() async {
    final villagesJson = await _provider.getActiveVillages();
    return villagesJson.map((village) => Village.fromJson(village)).toList();
  }

  Future<List<Sls>> getActiveSls() async {
    final slsJson = await _provider.getActiveSls();
    final villages = await getActiveVillages();
    final Map<String, Village> villageMap = {for (var v in villages) v.id: v};

    return slsJson.map((json) {
      final villageId = json['village_id'] as String;

      return Sls(
        id: json['id'].toString(),
        code: json['short_code'] as String,
        name: json['name'] as String,
        village: villageMap[villageId]!,
        isDeleted:
            json['is_deleted'] == 1, // Assuming is_deleted is stored as INTEGER
        hasDownloaded:
            json['has_downloaded'] == 1, // Assuming has_downloaded is INTEGER
      );
    }).toList();
  }

  Future<void> markVillagesAsDeleted(List<String> villageIds) async {
    await _provider.markVillagesAsDeleted(villageIds);
  }

  Future<void> reactivateVillages(List<String> villageIds) async {
    await _provider.reactivateVillages(villageIds);
  }

  Future<void> markSlsAsDeleted(List<String> slsIds) async {
    await _provider.markSlsAsDeleted(slsIds);
  }

  Future<void> reactivateSls(List<String> slsIds) async {
    await _provider.reactivateSls(slsIds);
  }

  Future<void> updateVillageDownloadStatus(
    String villageId,
    bool hasDownloaded,
  ) async {
    await _provider.updateVillageDownloadStatus(villageId, hasDownloaded);
  }

  Future<void> updateSlsDownloadStatus(String slsId, bool hasDownloaded) async {
    await _provider.updateSlsDownloadStatus(slsId, hasDownloaded);
  }

  Future<void> saveBusinesses(List<Business> businesses) async {
    final businessesJson =
        businesses.map((business) => business.toJson()).toList();
    await _provider.saveBusinesses(businessesJson);
  }

  Future<void> updateBusinessStatus(String businessId, String status) async {
    await _provider.updateBusinessStatus(businessId, status);
  }

  Future<List<Business>> getBusinessesBySls(String slsId) async {
    final sls = await getSlsById(slsId);

    final businessesJson = await _provider.getBusinessesBySls(slsId);
    return businessesJson.map((json) {
      return Business(
        id: json['id'] as String,
        name: json['name'] as String,
        owner: json['owner'] as String?,
        address: json['address'] as String?,
        sls: sls,
        status:
            json['status'] != null
                ? BusinessStatus.fromKey(json['status'])
                : BusinessStatus.notConfirmed,
      );
    }).toList();
  }

  Future<Sls> getSlsById(String slsId) async {
    final slsJson = await _provider.getSlsById(slsId);
    final villages = await getActiveVillages();
    final Map<String, Village> villageMap = {for (var v in villages) v.id: v};

    return Sls.fromJsonWithVillageMap(slsJson, villageMap);
  }
}
