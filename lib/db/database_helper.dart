import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/bike.dart';
import '../models/rental.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ridr.db');
    return openDatabase(
      path,
      // Keep the current schema version so installations that opened the
      // payment-method build do not hit a database downgrade.
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bikes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            model TEXT NOT NULL,
            number TEXT NOT NULL,
            colour TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'available',
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE rentals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bikeId INTEGER NOT NULL,
            customerName TEXT NOT NULL,
            age INTEGER NOT NULL,
            contactNumber TEXT NOT NULL,
            aadharNumber TEXT NOT NULL,
            personWithBikePhotoPath TEXT NOT NULL,
            licensePhotoPath TEXT NOT NULL,
            startDateTime TEXT NOT NULL,
            endDateTime TEXT NOT NULL,
            rentCharge REAL NOT NULL,
            deposit REAL NOT NULL,
            status TEXT NOT NULL DEFAULT 'active',
            actualReturnDateTime TEXT,
            paymentMethod TEXT,
            FOREIGN KEY (bikeId) REFERENCES bikes (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE rentals ADD COLUMN paymentMethod TEXT');
        }
      },
    );
  }

  // ---------- Bikes ----------

  Future<int> insertBike(Bike bike) async {
    final db = await database;
    return db.insert('bikes', bike.toMap()..remove('id'));
  }

  Future<List<Bike>> getAllBikes() async {
    final db = await database;
    final rows = await db.query('bikes', orderBy: 'createdAt DESC');
    return rows.map((r) => Bike.fromMap(r)).toList();
  }

  Future<List<Bike>> getAvailableBikes() async {
    final db = await database;
    final rows = await db.query(
      'bikes',
      where: 'status = ?',
      whereArgs: ['available'],
      orderBy: 'model ASC',
    );
    return rows.map((r) => Bike.fromMap(r)).toList();
  }

  Future<int> updateBikeStatus(int bikeId, String status) async {
    final db = await database;
    return db.update(
      'bikes',
      {'status': status},
      where: 'id = ?',
      whereArgs: [bikeId],
    );
  }

  Future<int> deleteBike(int bikeId) async {
    final db = await database;
    return db.delete('bikes', where: 'id = ?', whereArgs: [bikeId]);
  }

  // ---------- Rentals ----------

  Future<int> insertRental(Rental rental) async {
    final db = await database;
    return db.insert('rentals', rental.toMap()..remove('id'));
  }

  Future<List<Rental>> getActiveRentals() async {
    final db = await database;
    final rows = await db.query(
      'rentals',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'endDateTime ASC',
    );
    return rows.map((r) => Rental.fromMap(r)).toList();
  }

  Future<List<Rental>> getAllRentals() async {
    final db = await database;
    final rows = await db.query('rentals', orderBy: 'startDateTime DESC');
    return rows.map((r) => Rental.fromMap(r)).toList();
  }

  Future<int> completeRental(int rentalId, DateTime returnedAt) async {
    final db = await database;
    return db.update(
      'rentals',
      {
        'status': 'completed',
        'actualReturnDateTime': returnedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [rentalId],
    );
  }
}
