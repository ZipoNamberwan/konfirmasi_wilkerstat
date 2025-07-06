import 'package:konfirmasi_wilkerstat/model/village.dart';

class Sls {
  final String id;
  final String code;
  final String name;
  final Village village;

  Sls({
    required this.id,
    required this.code,
    required this.name,
    required this.village,
  });

  // Create Sls from JSON
  factory Sls.fromJson(Map<String, dynamic> json) {
    return Sls(
      id: json['id'].toString(),
      code: json['short_code'] as String,
      name: json['name'] as String,
      village: Village.fromJson(json['village'] as Map<String, dynamic>),
    );
  }

  // Convert Sls to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'short_code': code,
      'name': name,
      'village_id': village.id,
    };
  }

  // Create a copy with modified properties
  Sls copyWith({
    String? id,
    String? code,
    String? name,
    bool? isAdded,
    Village? village,
  }) {
    return Sls(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      village: village ?? this.village,
    );
  }
}
