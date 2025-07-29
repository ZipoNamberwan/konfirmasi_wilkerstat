import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/model/village.dart';

class Business {
  final String id;
  final String name;
  final String? owner;
  final String? address;
  final String latitude;
  final String longitude;
  final Sls sls;
  final BusinessStatus? status;

  Business({
    required this.id,
    required this.name,
    this.owner,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.sls,
    this.status,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      owner:
          (json['owner'] as String?)?.trim().isEmpty ?? true
              ? null
              : json['owner'],
      address:
          (json['initial_address'] as String?)?.trim().isEmpty ?? true
              ? null
              : json['initial_address'],
      latitude: json['lat']?.toString() ?? '',
      longitude: json['long']?.toString() ?? '',
      sls: Sls(
        id: json['sls_id'],
        code: '',
        name: '',
        village: Village(
          id: (json['sls_id'] as String).substring(0, 10),
          code: '',
          name: '',
          hasDownloaded: false,
          isDeleted: false,
        ),
        isDeleted: false,
        hasDownloaded: false,
        locked: false,
      ),
      status:
          (() {
            final statusKey = json['status_id'];
            return statusKey != null
                ? BusinessStatus.fromKey(statusKey)
                : BusinessStatus.notConfirmed;
          })(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'address': address,
      'lat': latitude,
      'long': longitude,
      'sls_id': sls.id,
      'status': status?.key,
    };
  }

  Map<String, dynamic> toJsonForUpload() {
    return {'id': id, 'status': status?.key};
  }

  // Create a copy with modified properties
  Business copyWith({
    String? id,
    String? name,
    String? owner,
    String? address,
    String? latitude,
    String? longitude,
    Sls? sls,
    BusinessStatus? status,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sls: sls ?? this.sls,
      status: status ?? this.status,
    );
  }
}

class BusinessStatus extends Equatable {
  final int key;
  final String text;

  const BusinessStatus({required this.key, required this.text});

  const BusinessStatus._(this.key, this.text);

  static const notConfirmed = BusinessStatus._(1, 'Belum Dikonfirmasi');
  static const found = BusinessStatus._(2, 'Ada');
  static const notFound = BusinessStatus._(3, 'Tidak Ada');

  static const values = [notConfirmed, found, notFound];

  static BusinessStatus? fromKey(int key) {
    return values.where((item) => item.key == key).firstOrNull;
  }

  static List<BusinessStatus> getStatuses() {
    return values;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'key': key, 'text': text};
  }

  /// Parse from JSON (returns null if key not found)
  static BusinessStatus? fromJson(Map<String, dynamic> json) {
    return fromKey(json['key']);
  }

  Color get color {
    if (this == BusinessStatus.notConfirmed) {
      return Colors.orange[600]!;
    } else if (this == BusinessStatus.found) {
      return Colors.green[600]!;
    } else if (this == BusinessStatus.notFound) {
      return Colors.red[600]!;
    } else {
      return Colors.grey[600]!;
    }
  }

  @override
  List<Object?> get props => [key, text];
}

class ImageUpload {
  final String id;
  final String slsId;
  final String imagePath;

  const ImageUpload({
    required this.id,
    required this.slsId,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'sls_id': slsId, 'image_path': imagePath};
  }

  factory ImageUpload.fromMap(Map<String, dynamic> map) {
    return ImageUpload(
      id: map['id'],
      slsId: map['sls_id'],
      imagePath: map['image_path'],
    );
  }
}
