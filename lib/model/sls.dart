import 'package:konfirmasi_wilkerstat/model/village.dart';

class Sls {
  final String id;
  final String code;
  final String name;
  final Village village;
  final bool isDeleted;
  final bool hasDownloaded;
  final bool locked;

  Sls({
    required this.id,
    required this.code,
    required this.name,
    required this.village,
    required this.isDeleted,
    required this.hasDownloaded,
    required this.locked,
  });

  // Create Sls from JSON
  factory Sls.fromJson(Map<String, dynamic> json) {
    return Sls(
      id: json['id'].toString(),
      code: json['short_code'] as String,
      name: json['name'] as String,
      village: Village.fromJson(json['village'] as Map<String, dynamic>),
      isDeleted: (json['is_deleted'] ?? 0) == 1,
      hasDownloaded: (json['has_downloaded'] ?? 0) == 1,
      locked: (json['locked'] ?? 0) == 1,
    );
  }

  factory Sls.fromJsonWithVillageMap(
    Map<String, dynamic> json,
    Map<String, Village> villageMap,
  ) {
    final villageId = json['village_id'] as String;

    return Sls(
      id: json['id'].toString(),
      code: json['short_code'] as String,
      name: json['name'] as String,
      village: villageMap[villageId]!,
      isDeleted: (json['is_deleted'] ?? 0) == 1,
      hasDownloaded: (json['has_downloaded'] ?? 0) == 1,
      locked: (json['locked'] ?? 0) == 1,
    );
  }

  // Convert Sls to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'short_code': code,
      'name': name,
      'village_id': village.id,
      'is_deleted': isDeleted ? 1 : 0,
      'has_downloaded': hasDownloaded ? 1 : 0,
      'locked': locked ? 1 : 0,
    };
  }

  // Create a copy with modified properties
  Sls copyWith({
    String? id,
    String? code,
    String? name,
    bool? isAdded,
    Village? village,
    bool? isDeleted,
    bool? hasDownloaded,
    bool? locked,
  }) {
    return Sls(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      village: village ?? this.village,
      isDeleted: isDeleted ?? this.isDeleted,
      hasDownloaded: hasDownloaded ?? this.hasDownloaded,
      locked: locked ?? this.locked,
    );
  }
}
