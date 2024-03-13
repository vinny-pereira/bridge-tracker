import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper{
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const String databaseName = 'bridge_notifications.db';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE scheduled_notifications (
  id $textType,
  bridge $textType,
  time $textType,
  notificationId $textType
)
    ''');
  }

  static Future<List<BridgeNotification>> fetchNotificationsByNotificationId(String notificationId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scheduled_notifications',
      where: 'notificationId = ?',
      whereArgs: [notificationId],
    );

    return List.generate(maps.length, (i) {
      return BridgeNotification(
        id: maps[i]['id'],
        bridge: maps[i]['bridge'],
        time: maps[i]['time'],
        notificationId: maps[i]['notificationId'],
      );
    });
  }

  static Future<int> createNotification(BridgeNotification notification) async {
    final db = await instance.database;
    final id = await db.insert('scheduled_notifications', notification.toJson());
    return id;
  }
}

class BridgeNotification{
  String id;
  String bridge;
  String notificationId;
  String time;

  BridgeNotification({
    String? id,
    required this.bridge,
    required this.time,
    required this.notificationId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bridge': bridge,
      'time': time,
      'notificationId': notificationId,
    };
  }
}