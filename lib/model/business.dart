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
}

enum BusinessStatus { found, notFound }
