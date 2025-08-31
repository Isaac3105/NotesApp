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
  late final TextEditingController _searchController;
  String _searchQuery = "";
  bool _isSearching = false;
  
  String get userId => AuthService.firebase().currentUser!.uid;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search notes...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color, fontSize: 18),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text("My Notes"),
        actions: [
          if (_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = "";
                  _searchController.clear();
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
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
                        const SizedBox(width: 12),
                        const Text("Logout"),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ],
      ),
      body: StreamBuilder(
        stream: _isSearching && _searchQuery.isNotEmpty
            ? _notesService.searchNotes(
                ownerUserId: userId, 
                searchQuery: _searchQuery,
                sortBy: NoteSortOption.updatedAt,
              )
            : _notesService.allNotes(ownerUserId: userId, sortBy: NoteSortOption.updatedAt),
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
                  return _isSearching && _searchQuery.isNotEmpty 
                      ? _buildNoSearchResults()
                      : _buildEmptyState();
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
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
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
    return Align(
      alignment: const Alignment(0, -0.6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
    );
  }

  Widget _buildNoSearchResults() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Results Found",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No notes match "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = "";
                  _searchController.clear();
                });
              },
              child: const Text(
                "Clear Search",
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
