import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a habit in the application
class Habit {
  final String? id;  // Unique identifier for the habit
  final String userId;  // ID of the user who owns this habit
  final String name;  // Name of the habit
  final String detail;  // Detailed description of the habit
  final String frequency;  // How often the habit should be performed (e.g., daily, weekly)
  final int numberOfDays;  // Number of days for the habit (might be used for streak or duration)
  final DateTime createdAt;  // When the habit was created
  final Map<String, HabitEntry> entries;  // Map of habit entries, keyed by some identifier (possibly date)

  // Constructor for Habit
  Habit({
    this.id,
    required this.userId,
    required this.name,
    required this.detail,
    required this.frequency,
    required this.numberOfDays,
    DateTime? createdAt,
    Map<String, HabitEntry>? entries,
  })  : createdAt = createdAt ?? DateTime.now(),  // Use provided date or current date
        entries = entries ?? {};  // Use provided entries or empty map
  
  // Converts Habit object to a map for Firestore
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

  // Creates a Habit object from a Firestore document
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

// Represents an entry for a habit on a specific date
class HabitEntry{
  final String? id;  // Unique identifier for the entry
  final String habitId;  // ID of the habit this entry belongs to
  final DateTime date;  // Date of this entry
  final bool isCompleted;  // Whether the habit was completed on this date
  final int streak;  // Current streak for the habit

  // Constructor for HabitEntry
  HabitEntry({
    this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = false,
    this.streak = 0,
  });

  // Converts HabitEntry object to a map for Firestore
  Map<String,dynamic> toMap(){
    return {
      "habitId" : habitId,
      "date" : Timestamp.fromDate(date),
      "isCompleted" : isCompleted,
      "streak" : streak
    };
  }

  // Creates a HabitEntry object from a Firestore document
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