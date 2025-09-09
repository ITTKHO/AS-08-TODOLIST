class Todo {
  final int? id;
  String title;
  String? description;
  DateTime? dueDate;
  int priority; // 1=High, 2=Medium, 3=Low
  bool isDone;
  DateTime createdAt;

  Todo({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 2,
    this.isDone = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'priority': priority,
      'is_done': isDone ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int),
      priority: (map['priority'] as int?) ?? 2,
      isDone: ((map['is_done'] as int?) ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
