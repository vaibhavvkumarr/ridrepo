import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/bike.dart';
import '../models/customer.dart';
import '../models/note.dart';
import '../models/rental.dart';
import '../models/staff.dart';

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
      version: 4,
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
          CREATE TABLE customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            aadharNumber TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            contactNumber TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE rentals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bikeId INTEGER NOT NULL,
            customerId INTEGER,
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
            rating INTEGER,
            FOREIGN KEY (bikeId) REFERENCES bikes (id),
            FOREIGN KEY (customerId) REFERENCES customers (id)
          )
        ''');
        await db.execute('''
          CREATE TABLE staff (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            role TEXT NOT NULL,
            joiningDate TEXT NOT NULL,
            salary REAL NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE rentals ADD COLUMN paymentMethod TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE customers (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              aadharNumber TEXT NOT NULL UNIQUE,
              name TEXT NOT NULL,
              age INTEGER NOT NULL,
              contactNumber TEXT NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
          await db.execute('ALTER TABLE rentals ADD COLUMN customerId INTEGER');
          await db.execute('ALTER TABLE rentals ADD COLUMN rating INTEGER');

          // Backfill a customer per distinct Aadhar number already on file,
          // then link existing rentals to it.
          final existing = await db.query('rentals',
              columns: [
                'aadharNumber',
                'customerName',
                'age',
                'contactNumber',
                'startDateTime'
              ],
              orderBy: 'startDateTime ASC');
          final seen = <String, int>{};
          for (final row in existing) {
            final aadhar = row['aadharNumber'] as String;
            if (seen.containsKey(aadhar)) continue;
            final customerId = await db.insert('customers', {
              'aadharNumber': aadhar,
              'name': row['customerName'],
              'age': row['age'],
              'contactNumber': row['contactNumber'],
              'createdAt': row['startDateTime'],
            });
            seen[aadhar] = customerId;
          }
          for (final entry in seen.entries) {
            await db.update(
              'rentals',
              {'customerId': entry.value},
              where: 'aadharNumber = ?',
              whereArgs: [entry.key],
            );
          }
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE staff (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              phone TEXT NOT NULL,
              role TEXT NOT NULL,
              joiningDate TEXT NOT NULL,
              salary REAL NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              text TEXT NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  /// Wipes the whole database file so the app can start fresh. The manager
  /// still has to go through onboarding again afterwards.
  Future<void> resetAll() async {
    final db = await database;
    final path = db.path;
    await db.close();
    await deleteDatabase(path);
    _db = null;
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

  // ---------- Customers ----------

  /// Finds the customer for [aadharNumber], creating one if this Aadhar
  /// number has never been seen before. This is the customer's stable,
  /// unique id — every rental made with the same Aadhar number links back
  /// to the same customer record.
  Future<int> upsertCustomer({
    required String aadharNumber,
    required String name,
    required int age,
    required String contactNumber,
  }) async {
    final db = await database;
    final rows = await db.query(
      'customers',
      where: 'aadharNumber = ?',
      whereArgs: [aadharNumber],
    );
    if (rows.isNotEmpty) {
      final id = rows.first['id'] as int;
      await db.update(
        'customers',
        {'name': name, 'age': age, 'contactNumber': contactNumber},
        where: 'id = ?',
        whereArgs: [id],
      );
      return id;
    }
    return db.insert(
      'customers',
      Customer(
        aadharNumber: aadharNumber,
        name: name,
        age: age,
        contactNumber: contactNumber,
      ).toMap()
        ..remove('id'),
    );
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final rows = await db.query('customers', orderBy: 'createdAt DESC');
    return rows.map((r) => Customer.fromMap(r)).toList();
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

  Future<int> completeRental(
    int rentalId,
    DateTime returnedAt, {
    int? rating,
  }) async {
    final db = await database;
    return db.update(
      'rentals',
      {
        'status': 'completed',
        'actualReturnDateTime': returnedAt.toIso8601String(),
        if (rating != null) 'rating': rating,
      },
      where: 'id = ?',
      whereArgs: [rentalId],
    );
  }

  // ---------- Staff ----------

  Future<int> insertStaff(Staff staff) async {
    final db = await database;
    return db.insert('staff', staff.toMap()..remove('id'));
  }

  Future<List<Staff>> getAllStaff() async {
    final db = await database;
    final rows = await db.query('staff', orderBy: 'createdAt DESC');
    return rows.map((r) => Staff.fromMap(r)).toList();
  }

  Future<int> deleteStaff(int staffId) async {
    final db = await database;
    return db.delete('staff', where: 'id = ?', whereArgs: [staffId]);
  }

  // ---------- Notes ----------

  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert('notes', note.toMap()..remove('id'));
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'createdAt DESC');
    return rows.map((r) => Note.fromMap(r)).toList();
  }

  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [noteId]);
  }
}
