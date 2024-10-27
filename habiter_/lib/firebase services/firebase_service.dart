import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habiter_/models/habit.dart';

/// FirebaseService handles all interactions with Firebase for habit tracking.
/// It manages habits and their entries in Firestore, including creation,
/// retrieval, and updates.
class FirebaseService {
  // Initialize Firestore and Auth instances for database operations and user authentication
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Reference to the 'habits' collection in Firestore.
  /// This collection stores all habits for all users.
  CollectionReference get _habits => _firestore.collection('habits');

  CollectionReference get _overallStreaks =>
      _firestore.collection('overallStreaks');

  /// Get a reference to the 'entries' subcollection for a specific habit.
  /// Each habit has its own 'entries' subcollection to track daily progress.
  /// @param habitId The unique identifier of the habit
  CollectionReference _entriesCollection(String habitId) =>
      _habits.doc(habitId).collection('entries');

  /// Get the current user's ID.
  /// This is used to associate habits with the logged-in user.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Adds a new habit to Firestore and creates initial entries if it's a daily habit.
  /// @param name The name of the habit
  /// @param detail Additional details about the habit
  /// @param numberOfDays The duration for which the habit should be tracked
  /// @param frequency How often the habit should be performed (e.g., 'daily')
  Future<void> addHabit(
      String name, String detail, int numberOfDays, String frequency) async {
    if (currentUserId == null) return;

    DocumentReference? habitsRef;
    try {
      // Add the main habit document to Firestore
      habitsRef = await _habits.add({
        'userId': currentUserId,
        'name': name,
        'detail': detail,
        'frequency': frequency,
        'bestStreak': 0,
        'numberOfDays': numberOfDays,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error adding habit: $e');
      return;
    }

    // Use a batch write to efficiently create multiple entries
    final batch = _firestore.batch();

    // For daily habits, create an entry for each day in the tracking period
    if (frequency == 'daily') {
      final now = DateTime.now();

      for (int i = 0; i < numberOfDays; i++) {
        final date = now.add(Duration(days: i));
        final entryRef = _entriesCollection(habitsRef.id).doc();
        batch.set(entryRef, {
          'habitId': habitsRef.id,
          'date': date,
          'isCompleted': false,
          'streak': 0
        });
      }
    }

    // Commit the batch write to Firestore
    try {
      await batch.commit();
    } catch (e) {
      // ignore: avoid_print
      print('Error committing batch: $e');
      // If batch write fails, attempt to delete the main habit document to maintain consistency
      try {
        await habitsRef.delete();
      } catch (deleteError) {
        // ignore: avoid_print
        print('Error deleting habit after failed batch commit: $deleteError');
      }
    }
  }

  /// Retrieves a stream of habits for a specific date.
  /// This method filters habits based on the user and the given date.
  /// @param date The date for which to retrieve habits
  /// @return A stream of List<Habit> for the specified date
  Stream<List<Habit>> getHabitsForDate(DateTime date) {
    if (currentUserId == null) return Stream.value([]);

    return _habits
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .asyncMap((habitSnapshot) async {
      List<Habit> habits = [];
      List errors = [];

      // Process each habit document from the snapshot
      for (var doc in habitSnapshot.docs) {
        try {
          final habit = Habit.fromDocument(doc);
          // Retrieve entries for this habit on the specified date
          final entryRef = await _entriesCollection(habit.id!)
              .where('date',
                  isEqualTo: Timestamp.fromDate(
                      DateTime(date.year, date.month, date.day)))
              .get();
          final entries =
              entryRef.docs.map((e) => HabitEntry.fromDocument(e)).toList();

          // Include the habit if it has entries for this date or if it's a daily habit
          if (entries.isNotEmpty || habit.frequency == 'daily') {
            habits.add(habit);
          }
        } catch (e) {
          errors.add(e);
        }
        // If any errors occurred during processing, throw an exception
        if (errors.isNotEmpty) {
          print(errors);
          throw Exception(errors.join('\n'));
        }
      }
      return habits;
    }).handleError((error) {
      // ignore: avoid_print
      print('Error fetching habits: $error');
      return [];
    });
  }

  /// Updates the completion status of a habit for a specific date.
  /// This method also updates the streak count for the habit.
  /// @param habitId The unique identifier of the habit
  /// @param date The date for which to update the completion status
  /// @param isCompleted Whether the habit was completed on this date
  Future<void> updateHabitCompletion(
      String habitId, DateTime date, bool isCompleted) async {
    // Retrieve the entry document for the specified date
    final entryQuery = await _entriesCollection(habitId)
        .where('date',
            isEqualTo:
                Timestamp.fromDate(DateTime(date.year, date.month, date.day)))
        .get();
    if (entryQuery.docs.isEmpty) return;

    final entryDoc = entryQuery.docs.first;
    final entry = HabitEntry.fromDocument(entryDoc);

    // If the completion status hasn't changed, no update is needed
    if (entry.isCompleted == isCompleted) return;

    int newStreak;
    if (isCompleted) {
      // If marking as completed, check the previous day's entry to update streak
      final previousDate = date.subtract(Duration(days: 1));
      final previousEntry = await _entriesCollection(habitId)
          .where('date',
              isEqualTo: Timestamp.fromDate(DateTime(
                  previousDate.year, previousDate.month, previousDate.day)))
          .get();
      final previousEntryData =
          previousEntry.docs.first.data() as Map<String, dynamic>;
      if (previousEntry.docs.isNotEmpty &&
          previousEntryData['isCompleted'] == true) {
        newStreak = previousEntryData['streak'] + 1;
      } else {
        newStreak = 1;
      }
    } else {
      // If marking as not completed, reset the streak
      newStreak = 0;
    }

    // Update the entry in Firestore using a batch write
    final batch = _firestore.batch();
    batch.update(
        entryDoc.reference, {'isCompleted': isCompleted, 'streak': newStreak});
    try {
      await batch.commit();
    } catch (e) {
      // ignore: avoid_print
      print('Error updating habit completion: $e');
    }
  }

  /// Calculates the current streak for a given habit.
  /// A streak is defined as the number of consecutive days a habit has been completed.
  /// @param habitId The unique identifier of the habit
  /// @return The current streak count
  Future<int> getHabitStreak(String habitId) async {
    try {
      final today = DateTime.now();
      // Retrieve all entries up to today, ordered by date descending
      final entries = await _entriesCollection(habitId)
          .where('date', isLessThanOrEqualTo: today)
          .orderBy('date', descending: true)
          .get();

      int streak = 0;
      // Count consecutive completed entries, starting from the most recent
      for (var doc in entries.docs) {
        final entryData = doc.data() as Map<String, dynamic>;
        if (entryData['isCompleted'] == true) {
          streak++;
        } else {
          // Break the loop when we encounter the first non-completed entry
          break;
        }
      }
      return streak;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching habit streak: $e');
      return 0;
    }
  }

  Future<int> getOverAllStreak() async {
    final habits =
        await _habits.where('userId', isEqualTo: currentUserId).get();
    int overallStreak = await getHabitStreak(habits.docs.first.id);
    for (var habit in habits.docs) {
      final habitStreak = await getHabitStreak(habit.id);
      if (habitStreak < overallStreak) {
        overallStreak = habitStreak;
      }
    }
    return overallStreak;
  }

  Future<int> getOverallBestStreak() async {
    final currentOverallStreak = await getOverAllStreak();
    final overallStreakDoc = await _overallStreaks.doc(currentUserId).get();

    int bestStreak = currentOverallStreak;

    if (overallStreakDoc.exists) {
      final overallStreakData = overallStreakDoc.data() as Map<String, dynamic>;
      int previousBestStreak = overallStreakData['streak'] ?? 0;

      if (currentOverallStreak > previousBestStreak) {
        bestStreak = currentOverallStreak;
        await _overallStreaks.doc(currentUserId).set({'streak': bestStreak});
      } else {
        bestStreak = previousBestStreak;
      }
    } else {
      await _overallStreaks.doc(currentUserId).set({'streak': bestStreak});
    }

    return bestStreak;
  }

    Future<int> getHabitBestStreak(String habitId) async {
      try {
        final habitDoc = await _habits.doc(habitId).get();
        if (!habitDoc.exists) {
          throw Exception('Habit not found');
        }
        
        final habitData = habitDoc.data() as Map<String, dynamic>;
        final storedBestStreak = habitData['bestStreak'] ?? 0;
        final currentStreak = await getHabitStreak(habitId);

        if (currentStreak > storedBestStreak) {
          await updateHabitBestStreak(habitId, currentStreak);
          return currentStreak;
        }

        return storedBestStreak;
      } catch (e) {
        // ignore: avoid_print
        print('Error getting habit best streak: $e');
        return 0;
      }
    }

    Future<void> updateHabitBestStreak(String habitId, int bestStreak) async {
      try {
        await _habits.doc(habitId).update({'bestStreak': bestStreak});
      } catch (e) {
        // ignore: avoid_print
        print('Error updating habit best streak: $e');
        rethrow; // Re-throw the error for the calling function to handle if necessary
      }
    }

  /// Deletes a habit and all its associated entries from Firestore.
  /// @param habitId The unique identifier of the habit to be deleted.
  /// @return A Future that completes when the deletion is finished.
  Future<void> deleteHabit(String habitId) async {
    // Create a new write batch for atomic operations on entries
    final batch = _firestore.batch();

    try {
      // Fetch all entries associated with the habit
      final entries = await _entriesCollection(habitId).get();
      // Iterate through each entry and add a delete operation to the batch
      for (var doc in entries.docs) {
        batch.delete(doc.reference);
      }
      // Execute the batch operation to delete all entries atomically
      await batch.commit();
      // After all entries are deleted, remove the main habit document
      await _habits.doc(habitId).delete();
    } catch (e) {
      // If any error occurs during the deletion process
      // ignore: avoid_print
      print('Error deleting habit: $e');
      // Re-throw the error as an exception for the caller to handle
      throw Exception("Error deleting habit :$e");
    }
  }
}
