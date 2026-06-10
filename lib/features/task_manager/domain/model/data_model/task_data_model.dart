class TaskDataModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  const TaskDataModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
  });

  // Immutable update — never mutate the existing instance directly
  TaskDataModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskDataModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'is_completed': isCompleted ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory TaskDataModel.fromMap(Map<String, dynamic> map) => TaskDataModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        isCompleted: (map['is_completed'] as int) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
