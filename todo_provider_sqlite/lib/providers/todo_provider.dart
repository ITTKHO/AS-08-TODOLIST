import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/todo_db.dart';

enum Filter { all, active, done }
enum SortBy { created, dueDate, priority }

class TodoProvider extends ChangeNotifier {
  final _db = TodoDB();
  List<Todo> _items = [];
  bool _isLoading = false;

  // UI State
  Filter _filter = Filter.all;
  SortBy _sortBy = SortBy.created;
  String _query = '';

  List<Todo> get items {
    var list = List<Todo>.from(_items);

    // ค้นหา
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((t) =>
          t.title.toLowerCase().contains(q) ||
          (t.description ?? '').toLowerCase().contains(q)).toList();
    }

    // กรอง
    switch (_filter) {
      case Filter.active:
        list = list.where((t) => !t.isDone).toList();
        break;
      case Filter.done:
        list = list.where((t) => t.isDone).toList();
        break;
      case Filter.all:
        break;
    }

    // เรียง
    switch (_sortBy) {
      case SortBy.created:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortBy.dueDate:
        list.sort((a, b) {
          final aNull = a.dueDate == null;
          final bNull = b.dueDate == null;
          if (aNull && bNull) return 0;
          if (aNull) return 1; // null ไปท้าย
          if (bNull) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortBy.priority:
        list.sort((a, b) => a.priority.compareTo(b.priority));
        break;
    }

    return list;
  }

  bool get isLoading => _isLoading;
  Filter get filter => _filter;
  SortBy get sortBy => _sortBy;
  String get query => _query;

  int get total => _items.length;
  int get doneCount => _items.where((e) => e.isDone).length;
  int get activeCount => _items.where((e) => !e.isDone).length;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();
    _items = await _db.getTodos();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    int priority = 2,
  }) async {
    if (title.trim().isEmpty) return;
    final todo = Todo(
      title: title.trim(),
      description: description?.trim().isEmpty == true ? null : description?.trim(),
      dueDate: dueDate,
      priority: priority,
    );
    await _db.insertTodo(todo);
    await loadTodos();
  }

  Future<void> toggleDone(Todo todo) async {
    final updated = todo.copyWith(isDone: !todo.isDone);
    await _db.updateTodo(updated);
    final idx = _items.indexWhere((t) => t.id == todo.id);
    if (idx != -1) {
      _items[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> editTodo(Todo todo, {
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
  }) async {
    var updated = todo.copyWith(
      title: title ?? todo.title,
      description: description,
      dueDate: dueDate,
      priority: priority ?? todo.priority,
    );
    await _db.updateTodo(updated);
    final idx = _items.indexWhere((t) => t.id == todo.id);
    if (idx != -1) {
      _items[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(Todo todo) async {
    if (todo.id == null) return;
    await _db.deleteTodo(todo.id!);
    _items.removeWhere((t) => t.id == todo.id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _db.clearAll();
    _items = [];
    notifyListeners();
  }

  // UI State setters
  void setFilter(Filter f) {
    _filter = f;
    notifyListeners();
  }

  void setSort(SortBy s) {
    _sortBy = s;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }
}
