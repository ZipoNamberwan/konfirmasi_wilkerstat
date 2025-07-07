import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/model/village.dart';

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
      'sls_id': sls.id,
      'status': status?.key,
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

class BusinessStatus extends Equatable {
  final int key;
  final String text;

  const BusinessStatus({required this.key, required this.text});

  const BusinessStatus._(this.key, this.text);

  static const notConfirmed = BusinessStatus._(1, 'Belum Dikonfirmasi');
  static const found = BusinessStatus._(2, 'Ditemukan');
  static const notFound = BusinessStatus._(3, 'Tidak Ditemukan');

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
      return Colors.grey[600]!;
    } else if (this == BusinessStatus.found) {
      return Colors.green[600]!;
    } else if (this == BusinessStatus.notFound) {
      return Colors.red[600]!;
    } else {
      return Colors.orange[600]!;
    }
  }

  @override
  List<Object?> get props => [key, text];
}
