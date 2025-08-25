import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/constants/routes.dart';
import 'package:to_do_app/enums/menu_actions.dart';
import 'package:to_do_app/services/auth/auth_service.dart';
import 'package:to_do_app/services/auth/bloc/auth_bloc.dart';
import 'package:to_do_app/services/auth/bloc/auth_event.dart';
import 'package:to_do_app/services/cloud/cloud_note.dart';
import 'package:to_do_app/services/cloud/firebase_cloud_storage.dart';
import 'package:to_do_app/utils/dialogs/log_out_dialog.dart';
import 'package:to_do_app/views/notes/notes_list_view.dart';

class ToDoView extends StatefulWidget {
  const ToDoView({super.key});

  @override
  State<ToDoView> createState() => _ToDoViewState();
}

class _ToDoViewState extends State<ToDoView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.uid;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  void dispose() {
    // Don't close the database here since it's a singleton and other parts might still need it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do"),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut) {
                    if (context.mounted) {
                      context.read<AuthBloc>().add(AuthEventLogOut());
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: MenuAction.logout, child: Text("Logout")),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                print(allNotes.toString());
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
                  },
                  onTap: (note) {
                    Navigator.of(
                      context,
                    ).pushNamed(createUpdateNoteRoute, arguments: note);
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
