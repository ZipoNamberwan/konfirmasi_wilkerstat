class SlsUpload {
  final String id;
  final DateTime createdAt;
  final String slsId;

  SlsUpload({required this.id, required this.createdAt, required this.slsId});

  factory SlsUpload.fromJson(Map<String, dynamic> json) {
    return SlsUpload(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      slsId: json['sls_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'sls_id': slsId,
    };
  }
}
