import 'package:flutter/foundation.dart';
import 'package:to_do_app/services/crud/constants/notes_and_user_database_columns.dart';

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
