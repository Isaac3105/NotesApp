import 'package:flutter/material.dart';
import 'package:to_do_app/services/crud/database_note.dart';
import 'package:to_do_app/utils/dialogs/delete_note_dialog.dart';

typedef NoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: notes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
      itemBuilder: (context, index) {
        final note = notes[index];
        if (note.text.isEmpty) {
          return const SizedBox.shrink();
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ListTile(
            onTap: () {
              onTap(note);
            },
            title: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteNoteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: Icon(Icons.delete),
            ),
          ),
        );
      },
    );
  }
}
