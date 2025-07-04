import 'package:konfirmasi_wilkerstat/model/village.dart';

final Map<String, dynamic> dummyVillageData = {
  "village": {
    "id": "3513010001",
    "name": "Desa 1",
    "short_code": "3513010001",
    "sls": [
      {"id": "SLS001", "name": "SLS A", "short_code": "SLS001"},
      {"id": "SLS002", "name": "SLS B", "short_code": "SLS002"},
    ],
    "business": [
      {
        "id": "B001",
        "name": "Warung Bu Ani",
        "owner": "Bu Ani",
        "address": "Jl. Melati No. 1",
        "sls": "SLS001",
        "status": "found",
      },
      {
        "id": "B002",
        "name": "Toko Pak Budi",
        "owner": "Pak Budi",
        "address": "Jl. Kenanga No. 2",
        "sls": "SLS002",
        "status": "notFound",
      },
      {
        "id": "B003",
        "name": "Laundry Bersih",
        "owner": "Ibu Sari",
        "address": "Jl. Mawar No. 3",
        "sls": "SLS001",
        "status": "found",
      },
      {
        "id": "B004",
        "name": "Bengkel Pak Darto",
        "owner": "Pak Darto",
        "address": "Jl. Anggrek No. 4",
        "sls": "SLS002",
        "status": "notFound",
      },
      {
        "id": "B005",
        "name": "Kios Sembako Barokah",
        "owner": "Bu Rina",
        "address": "Jl. Dahlia No. 5",
        "sls": "SLS001",
        "status": "found",
      },
      {
        "id": "B006",
        "name": "Depot Es Cendol",
        "owner": "Pak Tono",
        "address": "Jl. Flamboyan No. 6",
        "sls": "SLS002",
        "status": "found",
      },
      {
        "id": "B007",
        "name": "Toko Elektronik Jaya",
        "owner": "Bu Ani",
        "address": "Jl. Teratai No. 7",
        "sls": "SLS001",
        "status": "notFound",
      },
      {
        "id": "B008",
        "name": "Studio Foto Smile",
        "owner": "Mas Deni",
        "address": "Jl. Sakura No. 8",
        "sls": "SLS002",
        "status": "found",
      },
      {
        "id": "B009",
        "name": "Salon Ayu",
        "owner": "Mbak Yuli",
        "address": "Jl. Kamboja No. 9",
        "sls": "SLS001",
        "status": "notFound",
      },
      {
        "id": "B010",
        "name": "Warung Kopi Malam",
        "owner": "Mas Udin",
        "address": "Jl. Cemara No. 10",
        "sls": "SLS002",
        "status": "found",
      },
    ],
  },
};

final List<Village> dummyVillages = [
  Village(id: "3513010001", code: "3513010001", name: "Desa 1"),
  Village(id: "3513010002", code: "3513010002", name: "Desa 2"),
  Village(id: "3513010003", code: "3513010003", name: "Desa 3"),
];
