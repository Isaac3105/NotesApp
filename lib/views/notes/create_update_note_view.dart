import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:notes_app/utils/dialogs/error_dialog.dart';
import 'package:notes_app/utils/generics/get_arguments.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final quill.QuillController _contentController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _contentController = quill.QuillController.basic();
    _titleController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (note != null && _contentController.document.toPlainText().isEmpty && _titleController.text.isEmpty) {
      _notesService.deleteNote(documentId: note.documentId);
      _note = null;
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    if (note != null && (_contentController.document.toPlainText().isNotEmpty || _titleController.text.isNotEmpty)) {
      try {
        await _notesService.updateNote(
          title: _titleController.text,
          documentId: note.documentId,
          content: jsonEncode(_contentController.document.toDelta().toJson()),
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
        final content = jsonEncode(_contentController.document.toDelta().toJson());
        final title = _titleController.text;
        await _notesService.updateNote(documentId: note.documentId, content: content, title: title);
      } catch (e) {
        if(mounted) await showErrorDialog(context, "Could not update note.");
      }
    }
  }

  void _setupTextAndTitleControllerListener() {
    _contentController.removeListener(_textControllerListener);
    _contentController.addListener(_textControllerListener);
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
      final delta = Delta.fromJson(jsonDecode(widgetNote.text) as List);
      if ((delta.toJson()).isNotEmpty) {
        try {
          final delta = Delta.fromJson(jsonDecode(widgetNote.text) as List);
          _contentController.document = quill.Document.fromDelta(delta);
        } catch (e) {
          _contentController.document = quill.Document()..insert(0, widgetNote.text);
        }
      }
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
              final text = _contentController.document.toPlainText();
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
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  primaryColor: Colors.blue,
                                  colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: const Color.fromARGB(255, 253, 205, 94),
                                    onPrimary: Colors.white,
                                  ),
                                ),
                                child: quill.QuillSimpleToolbar(
                                  controller: _contentController,
                                  config: quill.QuillSimpleToolbarConfig(
                                    showBoldButton: true,
                                    showItalicButton: true,
                                    showUnderLineButton: false,
                                    showStrikeThrough: false,
                                    
                                    showFontSize: false,
                                    
                                    showListNumbers: true,
                                    showListBullets: true,
                                    showListCheck: true,
                                    
                                    showUndo: true,
                                    showRedo: true,
                                    
                                    showFontFamily: false,
                                    showColorButton: false,
                                    showBackgroundColorButton: false,
                                    showClearFormat: false,
                                    showAlignmentButtons: false,
                                    showLeftAlignment: false,
                                    showCenterAlignment: false,
                                    showRightAlignment: false,
                                    showJustifyAlignment: false,
                                    showInlineCode: false,
                                    showCodeBlock: false,
                                    showHeaderStyle: false,
                                    showQuote: false,
                                    showIndent: false,
                                    showLink: false,
                                    showDirection: false,
                                    showSearchButton: false,
                                    showSuperscript: false,
                                    showSubscript: false,
                                    
                                    embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8.0),
                              child: quill.QuillEditor.basic(
                                controller: _contentController,
                                config: quill.QuillEditorConfig(
                                  placeholder: 'Start typing your note...',
                                  embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                                ),
                              ),
                            ),
                          ),
                        ],
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
