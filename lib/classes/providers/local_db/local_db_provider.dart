import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// adb shell "run-as kendedes.douwes.dekker cat /data/user/0/kendedes.douwes.dekker/app_flutter/tagging_app.db" > my_local_db.db
class LocalDbProvider {
  static final LocalDbProvider _instance = LocalDbProvider._internal();
  factory LocalDbProvider() => _instance;

  LocalDbProvider._internal();

  bool _initialized = false;
  late Database _database;

  Future<void> init() async {
    if (_initialized) return;
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = '${documentsDirectory.path}/tagging_app.db';
    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
    _initialized = true;
  }

  Database get db {
    if (!_initialized) {
      throw Exception("Database not initialized. Call init() first.");
    }
    return _database;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE village (
      id TEXT PRIMARY KEY,
      short_code TEXT NOT NULL,
      name TEXT NOT NULL,
      has_downloaded INTEGER NOT NULL DEFAULT 0,
      is_deleted INTEGER NOT NULL DEFAULT 0
    );
  ''');

    await db.execute('''
    CREATE TABLE sls (
      id TEXT PRIMARY KEY,
      short_code TEXT NOT NULL,
      name TEXT NOT NULL,
      village_id TEXT NOT NULL,
      has_downloaded INTEGER NOT NULL DEFAULT 0,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      locked INTEGER NOT NULL DEFAULT 0,
      latitude REAL,
      longitude REAL,
      sls_chief_name TEXT,
      sls_chief_phone TEXT,
      FOREIGN KEY(village_id) REFERENCES village(id) ON DELETE CASCADE
    );
  ''');

    await db.execute('''
    CREATE TABLE business (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      owner TEXT,
      address TEXT,
      sls_id TEXT NOT NULL,
      status INTEGER NOT NULL DEFAULT 1,
      FOREIGN KEY(sls_id) REFERENCES sls(id) ON DELETE CASCADE
    );
  ''');

    await db.execute('''
    CREATE TABLE image_upload (
      id TEXT PRIMARY KEY,
      path TEXT NOT NULL,
      sls_id TEXT NOT NULL,
      FOREIGN KEY(sls_id) REFERENCES sls(id) ON DELETE CASCADE
    );
  ''');

    await db.execute('''
    CREATE TABLE sls_upload (
      id TEXT PRIMARY KEY,
      created_at TEXT NOT NULL,
      sls_id TEXT NOT NULL,
      FOREIGN KEY(sls_id) REFERENCES sls(id) ON DELETE CASCADE
    );
    ''');
  }
}
