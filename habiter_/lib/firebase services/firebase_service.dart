import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habiter_/models/habit.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get habits collection reference
  CollectionReference get _habits => _firestore.collection('habits');

  // Get entries collection reference for a habit
  CollectionReference _entriesCollection(String habitId) =>
      _habits.doc(habitId).collection('entries');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> addHabit(
      String name, String detail, int numberOfDays, String frequency) async {
    if (currentUserId == null) return;

    DocumentReference? habitsRef;
    try {
      habitsRef = await _habits.add({
        'userId': currentUserId,
        'name': name,
        'detail': detail,
        'frequency': frequency,
        'numberOfDays': numberOfDays,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error adding habit: $e');
      return;
    }
    final batch = _firestore.batch();
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
    try {
      await batch.commit();
    } catch (e) {
      // ignore: avoid_print
      print('Error committing batch: $e');
      try {
        await habitsRef.delete();
      } catch (deleteError) {
        // ignore: avoid_print
        print('Error deleting habit after failed batch commit: $deleteError');
      }
    }
  }
}
