import 'package:konfirmasi_wilkerstat/classes/providers/assignment_provider.dart';

class AssignmentRepository {
  static final AssignmentRepository _instance =
      AssignmentRepository._internal();
  factory AssignmentRepository() => _instance;

  AssignmentRepository._internal();

  late AssignmentProvider _assignmentProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _assignmentProvider = AssignmentProvider();
    await _assignmentProvider.init();
  }

  Future<Map<String, dynamic>> getAssignments() async {
    return await _assignmentProvider.getAssignments();
  }

  Future<List<Map<String, dynamic>>> downloadBusinessesByVillage(
    String villageId,
  ) async {
    final businessesJson = await _assignmentProvider
        .downloadBusinessesByVillage(villageId);

    return businessesJson
        .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
        .toList();
  }
}
