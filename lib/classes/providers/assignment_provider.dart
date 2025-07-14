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

  Future<List<dynamic>> downloadBusinessesByVillage(
    String villageId,
  ) async {
    final response = await _dioService.dio.get(
      '/assignments/wilkerstat/village/$villageId',
    );
    return response.data['data'];
  }

  Future<List<dynamic>> downloadBusinessesBySls(
    String slsId,
  ) async {
    final response = await _dioService.dio.get(
      '/assignments/wilkerstat/sls/$slsId',
    );
    return response.data['data'];
  }

}
