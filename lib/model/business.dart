import 'package:konfirmasi_wilkerstat/model/sls.dart';

class Business {
  final String id;
  final String name;
  final String? owner;
  final String? address;
  final Sls sls;
  final BusinessStatus? status;

  Business({
    required this.id,
    required this.name,
    this.owner,
    this.address,
    required this.sls,
    this.status,
  });

  // Create Business from JSON
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      owner: json['owner'] as String?,
      address: json['address'] as String?,
      sls: Sls.fromJson(json['sls'] as Map<String, dynamic>),
      status: null,
    );
  }

  // Convert Business to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status?.indexKey,
    };
  }

  // Create a copy with modified properties
  Business copyWith({
    String? id,
    String? name,
    String? owner,
    String? address,
    Sls? sls,
    BusinessStatus? status,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      address: address ?? this.address,
      sls: sls ?? this.sls,
      status: status ?? this.status,
    );
  }
}

enum BusinessStatus {
  found,
  notFound;

  // Helper method to get display name
  String get displayName {
    switch (this) {
      case BusinessStatus.found:
        return 'Ditemukan';
      case BusinessStatus.notFound:
        return 'Tidak Ditemukan';
    }
  }

  int get indexKey {
    switch (this) {
      case BusinessStatus.found:
        return 2;
      case BusinessStatus.notFound:
        return 3;
    }
  }
}
