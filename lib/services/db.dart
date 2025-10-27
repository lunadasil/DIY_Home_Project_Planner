import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'diy_home.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE projects(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            due_date INTEGER
          );
        ''');
        await db.execute('''
          CREATE TABLE steps(
            id TEXT PRIMARY KEY,
            project_id TEXT,
            label TEXT,
            done INTEGER,
            deadline INTEGER
          );
        ''');
        await db.execute('''
          CREATE TABLE materials(
            id TEXT PRIMARY KEY,
            project_id TEXT,
            name TEXT,
            cost REAL,
            quantity REAL,
            unit TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE photos(
            id TEXT PRIMARY KEY,
            project_id TEXT,
            path TEXT,
            added_at INTEGER
          );
        ''');
      },
    );
    return _db!;
  }
}
