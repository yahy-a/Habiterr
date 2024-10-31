import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:habiter_/firebase%20services/firebase_service.dart';
import 'package:habiter_/models/habit.dart';

/// HabitProvider manages the state of habits and interacts with FirebaseService
class HabitProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
  // Instance of FirebaseService to handle Firebase operations
  final FirebaseService _firebaseService = FirebaseService();
  
  // The currently selected date, initialized to today
  DateTime _selectedDate = DateTime.now();
  
  // List to store habit objects
  final List<Habit> _habits = [];

  // Variables to store the progress
  int _total = 0;

  int _progress = 0;

  double _progressValue = 0;


  // Variables to store the habit details
  int _selectedWeekDay = DateTime.sunday;
  int _selectedMonthDay = 1;
  String _taskName = '';
  String _taskDetails = '';
  String _frequency = 'Daily';
  int _numberOfDays = 1;

  int get total => _total;

  int get progress => _progress;
  // Getter for progress
  
  double get progressValue => _progressValue;

  // Getter for task name
  String get taskName => _taskName;

  // Getter for selected week day
  int get selectedWeekDay => _selectedWeekDay;

  // Getter for selected month day
  int get selectedMonthDay => _selectedMonthDay;

  // Getter for task details
  String get taskDetails => _taskDetails;

  // Getter for frequency
  String get frequency => _frequency;

  // Getter for number of days
  int get numberOfDays => _numberOfDays;
  
  // Getter for habits list
  List<Habit> get habits => _habits;
  
  // Getter for selected date
  DateTime get selectedDate => _selectedDate;

  // Setter for progress
  void setProgress(int progress, int total) {
    if (_progress != progress || _total != total) {
      _progress = progress;
      _total = total;
      _progressValue = total > 0 ? double.parse((progress / total).toStringAsFixed(2)) : 0.0;
      notifyListeners();
    }
  }

  // Setter for selected week day
  void setSelectedWeekDay(int weekDay) {
    _selectedWeekDay = weekDay;
    notifyListeners();
  }

  // Setter for selected month day
  void setSelectedMonthDay(int monthDay) {
    _selectedMonthDay = monthDay;
    notifyListeners();
  }

  // Setter for task name
  void setTaskName(String name) {
    _taskName = name;
    notifyListeners();
  }

  // Setter for task details
  void setTaskDetails(String details) {
    _taskDetails = details;
    notifyListeners();
  }

  // Setter for frequency
  void setFrequency(String freq) {
    _frequency = freq;
    notifyListeners();
  }

  // Setter for number of days
  void setNumberOfDays(int days) {
    _numberOfDays = days;
    notifyListeners();
  }

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
  Future<void> addHabit() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firebaseService.addHabit(_taskName, _taskDetails, _numberOfDays, _frequency, _selectedWeekDay, _selectedMonthDay);
      
      // Reset form
      _taskName = '';
      _taskDetails = '';
      _numberOfDays = 1;
      _frequency = 'Daily';
    } catch (e) {
      _error = 'Failed to add habit: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the completion status of a habit
  /// @param habitId The ID of the habit to update
  /// @param isCompleted The new completion status
  Future<void> updateHabitCompletion(String habitId, bool isCompleted) async {
    try {
      print('HabitProvider: Updating habit $habitId to $isCompleted');
      print('Selected date: $_selectedDate');
      
      await _firebaseService.updateHabitCompletion(habitId, _selectedDate, isCompleted);
      
      // Force a refresh of the habits stream
      notifyListeners();
    } catch (e) {
      print('HabitProvider: Error updating habit completion: $e');
      rethrow;
    }
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

  Future<int> getHabitStreak(String habitId) async {
    return await _firebaseService.getHabitStreak(habitId);
  }

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }

}
