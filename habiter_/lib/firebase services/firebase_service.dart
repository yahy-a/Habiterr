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

  CollectionReference get _overallBestStreaks =>
      _firestore.collection('overallBestStreaks');

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
  Future<void> addHabit(String name, String detail, int numberOfDays,
      String frequency, int? selectedWeekDay, int? selectedMonthDay) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Validate inputs
    if (frequency == 'Weekly' && selectedWeekDay == null) {
      throw ArgumentError('Weekly frequency requires a selected day');
    }
    if (frequency == 'Monthly' && selectedMonthDay == null) {
      throw ArgumentError('Monthly frequency requires a selected day');
    }

    DocumentReference habitDoc;
    try {
      habitDoc = await _habits.add({
        'userId': currentUserId,
        'name': name,
        'detail': detail,
        'frequency': frequency,
        'bestStreak': 0,
        'currentStreak': 0,
        'numberOfDays': numberOfDays,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Document added with ID: ${habitDoc.id}'); // Add this

      await addEntries(
          habitId: habitDoc.id,
          numberOfDays: numberOfDays,
          frequency: frequency,
          selectedWeekDay: selectedWeekDay,
          selectedMonthDay: selectedMonthDay);

      return;
    } catch (e) {
      throw Exception('Failed to add habit: $e');
    }
  }

  Future<void> addEntries({
    required String habitId,
    required int numberOfDays,
    required String frequency,
    int? selectedWeekDay,
    int? selectedMonthDay,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    try {
      switch (frequency.toLowerCase()) {
        case 'daily':
          for (int i = 0; i < numberOfDays; i++) {
            final date = now.add(Duration(days: i));
            _addEntryToBatch(batch, habitId, date);
          }
          break;

        case 'weekly':
          if (selectedWeekDay == null)
            throw ArgumentError('Weekly frequency requires a day selection');
          final daysUntilWeekDay = (selectedWeekDay - now.weekday + 7) % 7;
          final nextWeekDay = now.add(Duration(days: daysUntilWeekDay));

          for (int i = 0; i < numberOfDays; i++) {
            final date = nextWeekDay.add(Duration(days: 7 * i));
            _addEntryToBatch(batch, habitId, date);
          }
          break;

        case 'weekdays':
          for (int i = 0; i < numberOfDays; i++) {
            final date = now.add(Duration(days: i));
            // Only add entries for Monday (1) through Friday (5)
            if (date.weekday >= 1 && date.weekday <= 5) {
              _addEntryToBatch(batch, habitId, date);
            }
          }
          break;

        case 'monthly':
          if (selectedMonthDay == null)
            throw ArgumentError('Monthly frequency requires a day selection');
          for (int i = 0; i < numberOfDays; i++) {
            final date = DateTime(now.year, now.month + i, selectedMonthDay);
            _addEntryToBatch(batch, habitId, date);
          }
          break;

        default:
          throw ArgumentError('Invalid frequency: $frequency');
      }

      await batch.commit();
    } catch (e) {
      await _habits.doc(habitId).delete(); // Cleanup if entries creation fails
      throw Exception('Failed to create habit entries: $e');
    }
  }

  void _addEntryToBatch(WriteBatch batch, String habitId, DateTime date) {
    final entryRef = _entriesCollection(habitId).doc();
    batch.set(entryRef, {
      'habitId': habitId,
      'date': date,
      'isCompleted': false,
      'streak': 0,
    });
  }

  /// Retrieves a stream of habits for a specific date.
  /// This method filters habits based on the user and the given date.
  /// @param date The date for which to retrieve habits
  /// @return A stream of List<Habit> for the specified date
  Stream<List<Habit>> getHabitsForDate(DateTime date) {
    print('getHabitsForDate called with date: ${date.toString()}');

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    print('Querying for dates between: ${startOfDay} and ${endOfDay}');

    return _habits
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .asyncMap((habitSnapshot) async {
      List<Habit> habits = [];

      for (var doc in habitSnapshot.docs) {
        try {
          final habit = Habit.fromDocument(doc);

          // Query entries between start and end of day
          final entryRef = await _entriesCollection(habit.id!)
              .where('date',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
              .where('date', isLessThan: Timestamp.fromDate(endOfDay))
              .get();

          print(
              'Found ${entryRef.docs.length} entries for ${habit.name} on ${startOfDay}');

          if (entryRef.docs.isNotEmpty) {
            // Create a map of entries
            Map<String, HabitEntry> entries = {};
            for (var entryDoc in entryRef.docs) {
              final entry = HabitEntry.fromDocument(entryDoc);
              final dateKey =
                  DateTime(entry.date.year, entry.date.month, entry.date.day)
                      .toString();
              entries[dateKey] = entry;
              print(
                  'Added entry for ${habit.name} on $dateKey with completion status: ${entry.isCompleted}');
            }

            // Create new habit instance with entries
            habits.add(habit.copyWithEntries(entries));
            print('Added habit: ${habit.name} with ${entries.length} entries');
          }
        } catch (e) {
          print('Error processing habit: $e');
        }
      }

      return habits;
    });
  }

  /// Updates the completion status of a habit for a specific date.
  /// This method also updates the streak count for the habit.
  /// @param habitId The unique identifier of the habit
  /// @param date The date for which to update the completion status
  /// @param isCompleted Whether the habit was completed on this date
  Future<void> updateHabitCompletion(
      String habitId, DateTime date, bool isCompleted) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      print(
          'FirebaseService: Updating habit $habitId for date $startOfDay to $isCompleted');

      final entryQuery = await _entriesCollection(habitId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      if (entryQuery.docs.isEmpty) {
        print('FirebaseService: No entry found for date $startOfDay');
        return;
      }

      final entryDoc = entryQuery.docs.first;
      print('FirebaseService: Found entry ${entryDoc.id}');

      await entryDoc.reference.update({
        'isCompleted': isCompleted,
      });
      print('FirebaseService: Successfully updated entry');
    } catch (e) {
      print('FirebaseService: Error updating habit completion: $e');
      throw Exception('Failed to update habit completion: $e');
    }
  }

  /// Calculates the current streak for a given habit.
  /// A streak is defined as the number of consecutive days a habit has been completed.
  /// @param habitId The unique identifier of the habit
  /// @return The current streak count
  
  Future<int> getHabitStreak(String habitId) async {
    final habitDoc = await _habits.doc(habitId).get();
    final habitData = habitDoc.data() as Map<String, dynamic>;
    return habitData['currentStreak'] ?? 0;
  }
  Future<void> updateHabitStreak(String habitId) async {
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
      // Update the habit's currentStreak property
      await _habits.doc(habitId).update({'currentStreak': streak});
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching habit streak: $e');
    }
  }

  Future<int> getOverAllStreak() async {
    final overallStreakDoc = await _overallStreaks.doc(currentUserId).get();
    final overallStreakData = overallStreakDoc.data() as Map<String, dynamic>;
    return overallStreakData['overallStreak'] ?? 0;
  }
  Future<void> updateOverAllStreak() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(Duration(days: 1));
      final habits =
          await _habits.where('userId', isEqualTo: currentUserId).get();

      if (habits.docs.isEmpty) {
      }

      // Start with oldest possible date as the last break point
      DateTime lastBreakDay = endOfDay;
      bool foundIncomplete = false;

      // Check each habit's entries
      for (var habit in habits.docs) {
        final entries = await _entriesCollection(habit.id)
            .where('date', isLessThanOrEqualTo: startOfDay)
            .orderBy('date', descending: true)
            .get();

        if (entries.docs.isNotEmpty) {
          // Find first incomplete entry for this habit
          for (var entry in entries.docs) {
            final entryData = entry.data() as Map<String, dynamic>;
            final entryDate = (entryData['date'] as Timestamp).toDate();

            if (entryData['isCompleted'] == false) {
              foundIncomplete = true;
              // Update lastBreakDay if this incomplete entry is more recent
              if (entryDate.isAfter(lastBreakDay)) {
                lastBreakDay =
                    DateTime(entryDate.year, entryDate.month, entryDate.day);
              }
              break;
            }
          }

          // If no incomplete entries found, use the oldest entry date
            if (!foundIncomplete && entries.docs.isNotEmpty) {
              final oldestEntry = entries.docs.last;
              final oldestEntryData =
                  oldestEntry.data() as Map<String, dynamic>;
              final oldestDate =
                  (oldestEntryData['date'] as Timestamp).toDate();

              if (oldestDate.isBefore(lastBreakDay)) {
                lastBreakDay =
                    DateTime(oldestDate.year, oldestDate.month, oldestDate.day);
              }
            }

        }
      }

      // Calculate days since last break
      final daysSinceLastBreak = endOfDay.difference(lastBreakDay).inDays;
      await _overallStreaks.doc(currentUserId).set({'overallStreak': daysSinceLastBreak});
      // Return streak only if there are days since last break
    } catch (e) {
      print('Error calculating overall streak: $e');
    }
  }


  Future<int> getOverallBestStreak() async {
    final overallStreakDoc = await _overallBestStreaks.doc(currentUserId).get();
    final overallStreakData = overallStreakDoc.data() as Map<String, dynamic>;
    return overallStreakData['overallBestStreak'] ?? 0;
  }
  Future<void> updateOverallBestStreak() async {
    final currentOverallStreak = await getOverAllStreak();
    final overallStreakDoc = await _overallBestStreaks.doc(currentUserId).get();

    int bestStreak = currentOverallStreak;

    if (overallStreakDoc.exists) {
      final overallStreakData = overallStreakDoc.data() as Map<String, dynamic>;
      int previousBestStreak = overallStreakData['overallBestStreak'] ?? 0;

      if (currentOverallStreak > previousBestStreak) {
        bestStreak = currentOverallStreak;
        await _overallBestStreaks.doc(currentUserId).set({'overallBestStreak': bestStreak});
      }
    } else {
      await _overallBestStreaks.doc(currentUserId).set({'overallBestStreak': bestStreak});
    }
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

  Future<void> updateHabit( String habitId, String name, String detail) async {
    try {
      await _habits.doc(habitId).update({'name': name, 'detail': detail});
    } catch (e) {
      // ignore: avoid_print
      print('Error updating habit: $e');
      rethrow;
    }
  }
}