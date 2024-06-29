import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Manages the SQLite database for storing and retrieving notification data.
class NotificationData {
  int id;
  String title;
  String content;
  String regno;
  String mdate;
  String msgid;

  NotificationData(
      {required this.id,
      required this.title,
      required this.content,
      required this.regno,
      required this.mdate,
      required this.msgid});
// This method is responsible for converting a NotificationData object into a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'regno': regno,
      'mdate': mdate,
      'msgid': msgid
    };
  }

/* This method is a named constructor (a factory constructor) that creates 
a NotificationData object from a Map<String, dynamic> representation.
It takes the map obtained from the database (which typically represents a single row in the table)
and uses its values to initialize the properties of the NotificationData object. */
  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
        id: map['id'],
        title: map['title'],
        content: map['content'],
        regno: map['regno'],
        mdate: map['mdate'].toString(),
        msgid: map['msgid']);
  }
}

class NotificationDatabaseHelper {
  //defining static constant items.
  static const _databaseName = "notifications.db";
  static const _databaseVersion = 1;

  static const table = 'notifications_table';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnContent = 'content';
  static const columnRegno = 'regno';
  static const columnmDate = 'mdate';
  static const columnmsgId = 'msgid';

  static Database? _database;
  final StreamController<NotificationData> _notificationStreamController =
      StreamController<NotificationData>.broadcast();

  Stream<NotificationData> get notificationStream =>
      _notificationStreamController.stream;

  Future<void> init() async {
    /* The class uses the path_provider package to get the 
    application documents directory for storing the database.*/
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    // openDatabase() method, passing the path, version, and onCreate callback.
    _database = await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

// onCreate method is called when the database is created for the first time.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
      $columnId INTEGER PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnContent TEXT NOT NULL,
      $columnRegno TEXT NOT NULL,
      $columnmDate TEXT NOT NULL,
      $columnmsgId TEXT NOT NULL
    )
  ''');
  }

/*_onUpgrade method is called when the database version is increased. 
It drops the existing table and recreates it with a new schema.*/
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Drop the existing table
      await db.execute('DROP TABLE IF EXISTS $table');

      // Recreate the table with the new schema
      await _onCreate(db, newVersion);
    }
  }

/* method inserts a NotificationData object into the database table using the insert method. 
It handles conflict resolution using ConflictAlgorithm.replace.*/
  Future<int> insertNotification(NotificationData notification) async {
    final db = _database;
    try {
      if (db != null) {
        final existingNotifications = await db.query(
          table,
          where: '$columnId = ?',
          whereArgs: [notification.id], // Use the id as the query argument
        );
        print(
            'Query: SELECT * FROM $table WHERE $columnId = ? (ID: ${notification.id})');

        print('Existing notifications: $existingNotifications');
        if (existingNotifications.isNotEmpty) {
          // A notification with the same ID already exists, don't insert
          print('Duplicate found');
          return -2; // You can choose an appropriate error code
        }

        final result = db.insert(table, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        _notificationStreamController
            .add(notification); // Notify the stream about the new notification

        print('database inserted');

        return result;
      } else {
        // Handle the case when the database is not initialized

        return -1; // Return a default value or an error code
      }
    } catch (e) {
      print("Error inserting notification: $e");
      return -1;
    }
  }

  Future<List<NotificationData>> getNotifications(
    String regno,
  ) async {
    final db = _database;
    if (db == null) {
      return [];
    }
    // final offset = (pageNumber - 1) * pageSize;
    final List<Map<String, dynamic>> maps = await db.query(table,
        orderBy: '$columnId DESC',
        // limit: pageSize,
        // offset: offset,
        where: '$columnRegno =?',
        whereArgs: [regno]);

    return List.generate(maps.length, (index) {
      return NotificationData.fromMap(maps[index]);
    });
  }

  Stream<List<NotificationData>> getNotificationsStream(String regno) async* {
    while (true) {
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate asynchronous data retrieval
      final notifications = await getNotifications(regno);
      yield notifications;
    }
  }

  Future<List<NotificationData>> getNotificationsAll(
      int pageNumber, int pageSize) async {
    final db = _database;
    if (db == null) {
      return [];
    }
    final offset = (pageNumber - 1) * pageSize;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      orderBy: '$columnId DESC',
      limit: pageSize,
      offset: offset,
    );

    return List.generate(maps.length, (index) {
      return NotificationData.fromMap(maps[index]);
    });
  }

  Stream<List<NotificationData>> getNotificationsAllStream(
      int pageNumber, int pageSize) async* {
    final db = _database;
    if (db == null) {
      yield [];
    } else {
      final offset = (pageNumber - 1) * pageSize;
      final List<Map<String, dynamic>> maps = await db.query(
        table,
        orderBy: '$columnId DESC',
        limit: pageSize,
        offset: offset,
      );

      yield List.generate(maps.length, (index) {
        return NotificationData.fromMap(maps[index]);
      });
    }
  }
}
