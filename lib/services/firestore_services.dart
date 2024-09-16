import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference notes = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.email)
      .collection('notes');

  // Add a new note
  Future<void> addNote(String title, String note) {
    return notes.add({
      'title': title,
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  // Read notes
  Stream<QuerySnapshot> getNotesStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  // Update note using given doc id
  Future<void> updateNote(String docID, String title, String note) {
    return notes.doc(docID).update({
      'title': title,
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  // Delete note
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }

  // Get a note by its ID
  Future<DocumentSnapshot> getNoteById(String docID) {
    return notes.doc(docID).get();
  }
}



