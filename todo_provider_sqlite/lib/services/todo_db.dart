import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/todo.dart';

class TodoDB {
  static final TodoDB _instance = TodoDB._internal();
  factory TodoDB() => _instance;
  TodoDB._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todos_pro.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            due_date INTEGER,
            priority INTEGER NOT NULL DEFAULT 2,
            is_done INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // เผื่ออัปสคีมาในอนาคต
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE todos ADD COLUMN description TEXT');
          await db.execute('ALTER TABLE todos ADD COLUMN due_date INTEGER');
          await db.execute('ALTER TABLE todos ADD COLUMN priority INTEGER NOT NULL DEFAULT 2');
          await db.execute('ALTER TABLE todos ADD COLUMN created_at INTEGER NOT NULL DEFAULT (strftime("%s","now")*1000)');
        }
      },
    );
  }

  // CRUD
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return db.insert('todos', todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final res = await db.query('todos', orderBy: 'is_done ASC, priority ASC, due_date IS NULL, due_date ASC, id DESC');
    return res.map((e) => Todo.fromMap(e)).toList();
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return db.update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('todos');
  }
}
