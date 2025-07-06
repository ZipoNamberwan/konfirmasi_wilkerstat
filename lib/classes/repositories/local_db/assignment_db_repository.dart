import 'package:konfirmasi_wilkerstat/classes/providers/local_db/assignment_db_provider.dart';
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
      );
    }).toList();
  }
}
