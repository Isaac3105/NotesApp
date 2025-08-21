import 'package:flutter/material.dart';
import 'package:to_do_app/services/auth/auth_service.dart';
import 'package:to_do_app/services/crud/database_note.dart';
import 'package:to_do_app/services/crud/notes_service.dart';
import 'package:to_do_app/utils/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (note != null && _textController.text.isEmpty) {
      _notesService.deleteNote(id: note.id);
      _note = null;
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    if (note != null && _textController.text.isNotEmpty) {
      await _notesService.updateNote(note: note, text: _textController.text);
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note != null) {
      final text = _textController.text;
      await _notesService.updateNote(note: note, text: text);
    }
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArguments<DatabaseNote>();
    if (widgetNote == null) {
      final existingNote = _note;
      if (existingNote != null) {
        return existingNote;
      }
      final user = AuthService.firebase().currentUser;
      final owner = await _notesService.getUser(email: user!.email!);
      final newNote = await _notesService.createNote(owner: owner);
      _note = newNote;
      return newNote;
    } else {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgetNote = context.getArguments<DatabaseNote>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widgetNote == null ? "New Note" : "Edit Note"),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Start typing your note :)",
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
