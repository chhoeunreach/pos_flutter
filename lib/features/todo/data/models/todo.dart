class Todo {
  String id;
  String title;
  String description;
  bool isCompleted;
  String priority;
  DateTime? dueDate;
  String category;
  DateTime createdAt;
  DateTime updatedAt;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = 'medium',
    this.dueDate,
    this.category = 'General',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
        priority: json['priority'] as String? ?? 'medium',
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
        category: json['category'] as String? ?? 'General',
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      );

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? priority,
    DateTime? dueDate,
    String? category,
  }) =>
      Todo(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        priority: priority ?? this.priority,
        dueDate: dueDate ?? this.dueDate,
        category: category ?? this.category,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
