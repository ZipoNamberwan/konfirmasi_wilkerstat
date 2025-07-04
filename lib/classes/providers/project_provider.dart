import 'package:konfirmasi_wilkerstat/classes/dummy_data.dart';
import 'package:konfirmasi_wilkerstat/classes/services/dio_service.dart';

class ProjectProvider {
  static final ProjectProvider _instance = ProjectProvider._internal();
  factory ProjectProvider() => _instance;

  ProjectProvider._internal();

  late DioService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
  }

  Future<Map<String, dynamic>> getVillage(String villageId) async {
    // TODO - Implement the API call to fetch assignments for the user
    final Map<String, dynamic> response = dummyVillageData;

    return response;
  }
}
