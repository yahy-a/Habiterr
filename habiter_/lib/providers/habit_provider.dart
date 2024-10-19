import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habiter_/database_helper.dart';
import 'package:habiter_/models/habit.dart';

class HabitsProvider with ChangeNotifier {
  List<Habit> _habits = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Habit> get habits => _habits;

  Future<void> fetchHabits() async {
    _habits = await _dbHelper.getHabits();
    notifyListeners();
  }

  Future<void> addHabit(String name, String detail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Habit newHabit = Habit(id: 0, userId: user.uid, name: name, detail: detail);
      await _dbHelper.insertHabit(newHabit);
      await fetchHabits();
      notifyListeners();
    }else{
      print('User is not logged in');
    }
  }

  Future<void> updateHabit(Habit habit) async {
    await _dbHelper.updateHabit(habit);
    await fetchHabits();
    notifyListeners();
  }

  Future<void> deleteHabit(int id) async {
    await _dbHelper.deleteHabit(id);
    await fetchHabits();
    notifyListeners();
  }
}
