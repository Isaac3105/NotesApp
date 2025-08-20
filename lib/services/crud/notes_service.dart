import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart';
import 'package:to_do_app/services/crud/crud_exceptions.dart';

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

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email =$email';

  @override
  operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = map[textColumn] as String;

  @override
  String toString() => 'Note, ID = $id, userId =$userId, text =$text';

  @override
  operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";

const createUserTable = '''
      CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';

const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS "notes" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES ""
      );
      ''';
