class Habit {
  final int? id; // The ID is required and cannot be null
  final String userId;
  final String name; // Name of the habit
  final String detail; // Details about the habit
  bool isCompleted; // Indicates if the habit is completed

  Habit({
    this.id,
    required this.userId,
    required this.name,
    this.isCompleted = false,
    required this.detail,
  });

  // Convert a Habit object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId':userId,
      'name': name,
      'detail': detail,
      'isCompleted': isCompleted ? 1 : 0, // Convert bool to int for SQLite
    };
  }

  // Convert a Map object into a Habit object
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      detail: map['detail'],
      isCompleted: map['isCompleted'] == 1, // Convert int back to bool
    );
  }
}