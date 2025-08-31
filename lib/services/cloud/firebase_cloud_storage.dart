import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_app/services/cloud/cloud_note.dart';
import 'package:to_do_app/services/cloud/cloud_storage_constants.dart';
import 'package:to_do_app/services/cloud/cloud_storage_exceptions.dart';

enum NoteSortOption {
  createdAt,
  updatedAt,
}

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection("notes");

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    try {
      final now = Timestamp.now();
      final document = await notes.add({
        titleField: "",
        ownerUserIdFieldName: ownerUserId,
        textField: "",
        createdAtField: now,
        updatedAtField: now,
      });
      final fetchedNote = await document.get();
      return CloudNote(
        documentId: fetchedNote.id,
        ownerUserId: ownerUserId,
        text: "", 
        createdAt: now, 
        title: "", 
        updatedAt: now,
      );
    } catch (e) {
      throw CouldNotCreateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({
    required String ownerUserId,
    NoteSortOption sortBy = NoteSortOption.createdAt, 
  }) {
    final String sortField = sortBy == NoteSortOption.createdAt 
        ? createdAtField 
        : updatedAtField;
        
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .orderBy(sortField, descending: true)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    return allNotes;
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
    required String title,
  }) async {
    try {
      await notes.doc(documentId).update({
        textField: text, 
        titleField: title, 
        updatedAtField: Timestamp.now(),
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
