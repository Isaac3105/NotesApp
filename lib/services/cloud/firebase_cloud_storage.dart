import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_app/services/cloud/cloud_note.dart';
import 'package:to_do_app/services/cloud/cloud_storage_constants.dart';
import 'package:to_do_app/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection("notes");

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    try {
      final timestamp = Timestamp.now();
      final document = await notes.add({
        titleField: "",
        ownerUserIdFieldName: ownerUserId,
        textField: "",
        timestampField: timestamp,
      });
      final fetchedNote = await document.get();
      return CloudNote(
        documentId: fetchedNote.id,
        ownerUserId: ownerUserId,
        text: "", 
        timestamp: timestamp, 
        title: "",
      );
    } catch (e) {
      throw CouldNotCreateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes.where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .orderBy(timestampField, descending: true)
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
      await notes.doc(documentId).update({textField: text, titleField: title});
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
