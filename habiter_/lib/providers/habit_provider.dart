import 'package:flutter/foundation.dart';
import 'package:habiter_/firebase%20services/firebase_service.dart';
import 'package:habiter_/models/habit.dart';

/// HabitProvider manages the state of habits and interacts with FirebaseService
class HabitProvider with ChangeNotifier {
  // Instance of FirebaseService to handle Firebase operations
  final FirebaseService _firebaseService = FirebaseService();
  
  // The currently selected date, initialized to today
  DateTime _selectedDate = DateTime.now();
  
  // List to store habit objects
  final List<Habit> _habits = [];
  
  // Getter for habits list
  List<Habit> get habits => _habits;
  
  // Getter for selected date
  DateTime get selectedDate => _selectedDate;

  /// Updates the selected date and notifies listeners
  /// @param date The new date to be set
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  /// Provides a stream of habits for the selected date
  Stream<List<Habit>> get habitsStream => _firebaseService.getHabitsForDate(_selectedDate);

  /// Adds a new habit to Firebase
  /// @param name The name of the habit
  /// @param detail Additional details about the habit
  /// @param numberOfDays The number of days for the habit
  /// @param frequency The frequency of the habit (default is 'daily')
  Future<void> addHabit(String name, String detail, int numberOfDays, String frequency) async {
    await _firebaseService.addHabit(name, detail, numberOfDays, frequency);
    notifyListeners();
  }

  /// Updates the completion status of a habit
  /// @param habitId The ID of the habit to update
  /// @param isCompleted The new completion status
  Future<void> updateHabitCompletion(String habitId, bool isCompleted) async {
    await _firebaseService.updateHabitCompletion(habitId, _selectedDate, isCompleted);
    notifyListeners();
  }

  /// Deletes a habit from Firebase
  /// @param habitId The ID of the habit to delete
  Future<void> deleteHabit(String habitId) async {
    await _firebaseService.deleteHabit(habitId);
    notifyListeners();
  }

  /// Gets the overall best streak for all habits 
  Future<int> getOverallBestStreak() async {
    return await _firebaseService.getOverallBestStreak();
  }

  /// Gets the overall streak for all habits
  Future<int> getOverallStreak() async {
    return await _firebaseService.getOverAllStreak();
  }

  Future<int> getHabitBestStreak(String habitId) async {
    return await _firebaseService.getHabitBestStreak(habitId);
  }

}
