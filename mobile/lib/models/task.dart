enum TaskStatus { TODO, IN_PROGRESS, DONE }

TaskStatus taskStatusFromString(String value) {
  return TaskStatus.values.firstWhere((e) => e.name == value, orElse: () => TaskStatus.TODO);
}

class Task {
  final int id;
  final String title;
  final String? description;
  final TaskStatus status;
  final String createdAt;
  final String updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: taskStatusFromString(json['status']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description ?? '',
        'status': status.name,
      };
}
