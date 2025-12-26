import 'package:konfirmasi_wilkerstat/classes/providers/project_provider.dart';

class ProjectRepository {
  static final ProjectRepository _instance = ProjectRepository._internal();
  factory ProjectRepository() => _instance;

  ProjectRepository._internal();

  late ProjectProvider _projectProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _projectProvider = ProjectProvider();
    await _projectProvider.init();
  }

  Future<Map<String, dynamic>> sendDataDirectToServer({
    required Map<String, dynamic> data,
  }) async {
    return await _projectProvider.sendDataDirectToServer(data: data);
  }
}
