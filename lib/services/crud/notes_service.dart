import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart';
import 'package:to_do_app/services/crud/constants/crate_user_table.dart';
import 'package:to_do_app/services/crud/constants/create_note_table.dart';
import 'package:to_do_app/services/crud/constants/database_name.dart';
import 'package:to_do_app/services/crud/constants/notes_and_user_database_columns.dart';
import 'package:to_do_app/services/crud/crud_exceptions.dart';
import 'package:to_do_app/services/crud/database_note.dart';
import 'package:to_do_app/services/crud/database_user.dart';

class NotesService {
  Database? _db;

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabseOrThrow();
    await getNote(id: note.id);

    final result = await db!.update(noteTable, {textColumn: text});

    if (result == 0) {
      throw CouldNotUpdateNoteException();
    }
    return await getNote(id: note.id);
  }

  Future<List<DatabaseNote>> getAllNotes({required int id}) async {
    final db = _getDatabseOrThrow();
    final notes = await db!.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow)).toList();
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabseOrThrow();
    final notes = await db!.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    }
    return DatabaseNote.fromRow(notes.first);
  }

  Future<int> deleteAllNotes({required int id}) async {
    final db = _getDatabseOrThrow();
    return await db!.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabseOrThrow();
    final deletedCount = await db!.delete(
      noteTable,
      where: 'id= ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }
    const text = '';
    final notesId = await db!.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
    });
    final note = DatabaseNote(id: notesId, userId: owner.id, text: text);
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabseOrThrow();
    final results = await db!.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    }
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _db;
    final results = await db!.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabseOrThrow();
    final deletedCount = await db!.delete(
      userTable,
      where: 'email= ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteUserException();
    }
  }

  Database? _getDatabseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }
    return db;
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      db.execute(createUserTable);

      db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }
    await db.close();
    _db = null;
  }
}
