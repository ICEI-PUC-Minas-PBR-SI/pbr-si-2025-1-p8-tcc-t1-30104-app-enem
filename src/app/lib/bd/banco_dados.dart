import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_data.db');

    return await openDatabase(
      path,
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE results ADD COLUMN subject TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE study_plan (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              subject TEXT,
              topic TEXT,
              progress INTEGER DEFAULT 0
            )
          ''');
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT,
            topic TEXT,
            correctAnswers INTEGER,
            totalQuestions INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE study_plan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT,
            topic TEXT,
            progress INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> insertResult(String subject, String topic, int correctAnswers, int totalQuestions) async {
    final db = await database;
    await db.insert(
      'results',
      {
        'subject': subject,
        'topic': topic,
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    int progress = ((correctAnswers / totalQuestions) * 100).toInt();
    await updateStudyProgressByTopic(subject, topic, progress);
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    final db = await database;
    return await db.query('results');
  }

  Future<void> deleteResult(int id) async {
    final db = await database;
    await db.delete(
      'results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertStudyTopic(String subject, String topic) async {
    final db = await database;
    await db.insert(
      'study_plan',
      {
        'subject': subject,
        'topic': topic,
        'progress': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Map<String, dynamic>>> getStudyPlan() async {
    final db = await database;
    return await db.query('study_plan');
  }

  Future<void> updateStudyProgressByTopic(String subject, String topic, int progress) async {
    final db = await database;
    await db.update(
      'study_plan',
      {'progress': progress},
      where: 'subject = ? AND topic = ?',
      whereArgs: [subject, topic],
    );
  }
}
