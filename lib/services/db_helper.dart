import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/firm_details.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'accounting_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE firm_details(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            address TEXT,
            phone TEXT,
            email TEXT,
            gstin TEXT
          )
        ''');
      },
    );
  }

  Future<int> saveFirmDetails(FirmDetails details) async {
    final db = await database;
    await db.delete('firm_details'); // Keep only single firm entry
    return await db.insert('firm_details', details.toMap());
  }

  Future<FirmDetails?> getFirmDetails() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('firm_details');
    if (maps.isNotEmpty) {
      return FirmDetails.fromMap(maps.first);
    }
    return null;
  }
}