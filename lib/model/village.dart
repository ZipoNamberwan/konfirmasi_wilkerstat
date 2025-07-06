class Village {
  final String id;
  final String code;
  final String name;
  final bool hasDownloaded;
  final bool isDeleted;

  Village({
    required this.id,
    required this.code,
    required this.name,
    required this.hasDownloaded,
    required this.isDeleted,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'].toString(),
      code: json['short_code'] as String,
      name: json['name'] as String,
      hasDownloaded: false,
      isDeleted: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'short_code': code, 'name': name};
  }
}
