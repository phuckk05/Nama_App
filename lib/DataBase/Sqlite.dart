import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteService {
  static Database? _database;
  static final SQLiteService instance = SQLiteService._internal();
  factory SQLiteService() => instance;
  SQLiteService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  //Tạo Sqlite
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'product.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {

    //không sài
    await db.execute('''
      CREATE TABLE product(
        id TEXT PRIMARY KEY,
        name TEXT,
        price REAL,
        total TEXT,
        email TEXT,
        address TEXT,
        type TEXT,
        image TEXT
      )
    ''');

    /*Tạo table user*/
    await db.execute('''
      CREATE TABLE users(
        email TEXT PRIMARY KEY
      )
    ''');
  }

  //thêm email user vào Table users
  Future<void> insertUser(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.insert('users', data);
  }

  //Kiểm tra table users
  Future<String?> getUserEmail() async {

    //Truy xuất database
    final db = await database;
    final result = await db.query('users');

    if (result.isNotEmpty) {
      //Có user
      return result.first['email'] as String;
    }

    //không có user
    return null; 
  }

  //Xóa email người dùng khi đăng xuất
  Future<void> DeleteUser(String email) async {
    //Xóa 
    final db = await database;
    await db.delete('users');
  }


  // Future<void> insertProduct(Map<String, dynamic> data) async {
  //   final db = await instance.database;
  //   await db.insert('product', data);
  // }

  // Future<List<Map<String, dynamic>>> getAllProducts() async {
  //   final db = await database;
  //   return await db.query('product');
  // }

  // Future<List<Map<String, dynamic>>> getProducts(String email) async {
  //   final db = await database;
  //   return await db.query('product', where: 'email = ?', whereArgs: [email]);
  // }

  // Future<void> clearAll() async {
  //   final db = await database;
  //   await db.delete('product');
  // }

  // Future<List<Map<String, dynamic>>> showProducts(String code) async {
  //   final db = await database;
  //   return await db.query('product', where: 'id = ?', whereArgs: [code]);
  // }
}
