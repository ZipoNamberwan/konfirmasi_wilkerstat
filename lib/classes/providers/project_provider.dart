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

  Future<Map<String, dynamic>> sendDataDirectToServer({
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioService.dio.post(
      '/assignments/wilkerstat/update',
      data: data,
    );

    return response.data;
  }
}
