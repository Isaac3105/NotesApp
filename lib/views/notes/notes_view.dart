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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        actions: [
          PopupMenuButton<MenuAction>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut) {
                    if (context.mounted) {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Theme.of(context).iconTheme.color,),
                      SizedBox(width: 12),
                      Text("Logout"),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId, sortBy: NoteSortOption.updatedAt),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                
                final validNotes = allNotes.where((note) => 
                  note.text.isNotEmpty || note.title.isNotEmpty
                ).toList();
                
                if (validNotes.isEmpty) {
                  return _buildEmptyState();
                }
                return NotesListView(
                  notes: validNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
                  },
                  onTap: (note) {
                    Navigator.of(context).pushNamed(
                      createUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                );
              }
              return _buildLoadingState();
            default:
              return _buildLoadingState();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(createUpdateNoteRoute);
        },
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          "New Note",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Loading your notes...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.note_add_outlined,
                size: 64,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Notes Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the + button to create your first note",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
