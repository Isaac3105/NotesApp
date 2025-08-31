import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:to_do_app/services/auth/auth_service.dart';
import 'package:to_do_app/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:to_do_app/utils/dialogs/error_dialog.dart';
import 'package:to_do_app/utils/generics/get_arguments.dart';
import 'package:to_do_app/services/cloud/cloud_note.dart';
import 'package:to_do_app/services/cloud/firebase_cloud_storage.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (note != null && _textController.text.isEmpty && _titleController.text.isEmpty) {
      _notesService.deleteNote(documentId: note.documentId);
      _note = null;
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    if (note != null && (_textController.text.isNotEmpty || _titleController.text.isNotEmpty)) {
      try {
        await _notesService.updateNote(
          title: _titleController.text,
          documentId: note.documentId,
          text: _textController.text,
        );
      } catch (e) {
        if(mounted) await showErrorDialog(context, "Could not update note.");
      }
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note != null) {
      try {
        final text = _textController.text;
        final title = _titleController.text;
        await _notesService.updateNote(documentId: note.documentId, text: text, title: title);
      } catch (e) {
        if(mounted) await showErrorDialog(context, "Could not update note.");
      }
    }
  }

  void _setupTextAndTitleControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
    _titleController.removeListener(_textControllerListener);
    _titleController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArguments<CloudNote>();
    if (widgetNote == null) {
      final existingNote = _note;
      if (existingNote != null) {
        return existingNote;
      }
      final user = AuthService.firebase().currentUser;
      final uid = user!.uid;
      final newNote = await _notesService.createNewNote(ownerUserId: uid);
      _note = newNote;
      return newNote;
    } else {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _titleController.text = widgetNote.title;
      return widgetNote;
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgetNote = context.getArguments<CloudNote>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widgetNote == null ? "New Note" : "Edit Note"),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              final title = _titleController.text;
              final shareText = title.isNotEmpty ? "$title\n\n$text" : text;
              
              if (_note == null || shareText.trim().isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                SharePlus.instance.share(ShareParams(text: shareText));
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextAndTitleControllerListener();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      autocorrect: true,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Note Title",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        autocorrect: true,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: "Start typing your note...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            default:
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              );
          }
        },
      ),
    );
  }
}
