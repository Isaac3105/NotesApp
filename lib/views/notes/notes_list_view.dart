import 'package:flutter/material.dart';
import 'package:to_do_app/services/cloud/cloud_note.dart';
import 'package:to_do_app/utils/dialogs/delete_note_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
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
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        if (note.text.isEmpty && note.title.isEmpty) {
          return const SizedBox.shrink();
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: ListTile(
            onTap: () {
              onTap(note);
            },
            title: Text(
              note.title == "" ? note.text : note.title,
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
