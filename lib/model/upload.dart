import 'package:konfirmasi_wilkerstat/model/sls.dart';

class SlsUpload {
  final String id;
  final DateTime createdAt;
  final Sls sls;

  SlsUpload({required this.id, required this.createdAt, required this.sls});

  factory SlsUpload.fromJson(Map<String, dynamic> json) {
    return SlsUpload(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      sls: Sls.fromJson(json['sls'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'sls_id': sls.id,
    };
  }
}
