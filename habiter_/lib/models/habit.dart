import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String? id;
  final String userId;
  final String name;
  final String detail;
  final String frequency;
  final int numberOfDays;
  final DateTime createdAt;
  final Map<String, HabitEntry> entries;

  Habit({
    this.id,
    required this.userId,
    required this.name,
    required this.detail,
    required this.frequency,
    required this.numberOfDays,
    DateTime? createdAt,
    Map<String, HabitEntry>? entries,
  })  : createdAt = createdAt ?? DateTime.now(),
        entries = entries ?? {};
  
  Map<String,dynamic> toMap(){
    return {
      'userId': userId,
      'name': name,
      'detail': detail,
      'frequency': frequency,
      'numberOfDays': numberOfDays,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Habit.fromDocument(DocumentSnapshot doc){
    final data = doc.data() as Map<String,dynamic>;
    return Habit(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      detail: data['detail'],
      frequency: data['frequency'],
      numberOfDays: data['numberOfDays'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class HabitEntry{
  final String? id;
  final String habitId;
  final DateTime date;
  final bool isCompleted;
  final int streak;

  HabitEntry({
    this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = false,
    this.streak = 0,
  });

  Map<String,dynamic> toMap(){
    return {
      "habitId" : habitId,
      "date" : Timestamp.fromDate(date),
      "isCompleted" : isCompleted,
      "streak" : streak
    };
  }

  factory HabitEntry.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String,dynamic>;
    return HabitEntry(
      id: doc.id,
      habitId: data['habitId'],
      date: (data['date'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      streak: data['streak'] ?? 0,
    );
  }

}
