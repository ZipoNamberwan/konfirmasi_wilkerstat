import 'package:konfirmasi_wilkerstat/classes/services/dio_service.dart';

class AssignmentProvider {
  static final AssignmentProvider _instance = AssignmentProvider._internal();
  factory AssignmentProvider() => _instance;

  AssignmentProvider._internal();

  late DioService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
  }

  Future<Map<String, dynamic>> getAssignments() async {
    final response = await _dioService.dio.get('/assignments/wilkerstat');
    return response.data['data'];
  }

  Future<List<dynamic>> downloadBusinessesByVillage(String villageId) async {
    final response = await _dioService.dio.get(
      '/assignments/wilkerstat/village/$villageId',
    );
    return response.data['data'];
  }

  Future<List<dynamic>> downloadBusinessesBySls(String slsId) async {
    final response = await _dioService.dio.get(
      '/assignments/wilkerstat/sls/$slsId',
    );
    return response.data['data'];
  }

  Future<List<dynamic>> downloadBusinessesByMultipleSls(
    List<String> slsIds,
  ) async {
    final response = await _dioService.dio.post(
      '/assignments/wilkerstat/multiple-sls',
      data: {'sls_ids': slsIds},
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> updatePrelistStatus(
    List<String> slsIds,
    bool downloaded,
  ) async {
    final response = await _dioService.dio.post(
      '/assignments/wilkerstat/prelist-status',
      data: {'sls_ids': slsIds, 'downloaded': downloaded},
    );
    return response.data['data'];
  }
}
