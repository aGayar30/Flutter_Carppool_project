import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String dbName = 'my_database.db';
  static const String tableName = 'user_profile';

  Future<Database> initializeDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, dbName);

    return await openDatabase(databasePath, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
            profilePictureUrl TEXT,
        name TEXT,
        age TEXT,
        grade TEXT,
        address TEXT,
        email TEXT,
        phoneNumber TEXT,
        major TEXT,
        carType TEXT
      )
    ''');
  }

  Future<void> insertOrUpdateUserProfile(Map<String, dynamic> userData) async {
    final db = await initializeDatabase();


    // Check if the user exists in the local database
    final existingUser = await db.query(tableName, where: 'id = ?', whereArgs: [1]);
    if (existingUser.isNotEmpty) {
      // Update user data
      await db.update(tableName, userData, where: 'id = ?', whereArgs: [1]);
    } else {
      // Insert user data
      await db.insert(tableName, userData);
    }

  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final db = await initializeDatabase();

    final result = await db.query(tableName, where: 'id = ?', whereArgs: [1]);

    if (result.isNotEmpty) {
      return result.first;
    }

    return {};
  }
}
