import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/notes/note_bloc.dart';
import 'note_editor_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final searchC = TextEditingController();
  String statusFilter = '';

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  void _reload() {
    context.read<NoteBloc>().add(NotesLoad(query: searchC.text, statusFilter: statusFilter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Notes'),
        actions: [
          IconButton(icon: const Icon(Icons.sync),
              onPressed: () => context.read<NoteBloc>().add(NotesSync())),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NoteEditorPage()));
          _reload();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: searchC,
              decoration: const InputDecoration(
                hintText: 'Search title, description, site, customer...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _reload(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              initialValue: statusFilter,
              decoration: const InputDecoration(
                  labelText: 'Status filter', border: OutlineInputBorder(), isDense: true),
              items: const [
                DropdownMenuItem(value: '', child: Text('All statuses')),
                DropdownMenuItem(value: 'OPEN', child: Text('OPEN')),
                DropdownMenuItem(value: 'IN_PROGRESS', child: Text('IN_PROGRESS')),
                DropdownMenuItem(value: 'DONE', child: Text('DONE')),
              ],
              onChanged: (v) {
                setState(() => statusFilter = v ?? '');
                _reload();
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<NoteBloc, NoteState>(
              listener: (context, state) {
                if (state.message != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message!)));
                }
              },
              builder: (context, state) {
                if (state.items.isEmpty) {
                  return const Center(child: Text('No notes yet. Tap + to add.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => context.read<NoteBloc>().add(NotesSync()),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final n = state.items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          title: Text(n.title),
                          subtitle: Text('${n.siteName} - ${n.customerName}\n${n.description}',
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          isThreeLine: true,
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            _statusChip(n.status),
                            if (n.dirty)
                              const Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                            PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'edit') {
                                  await Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => NoteEditorPage(existingLocalId: n.localId)));
                                  _reload();
                                } else {
                                  context.read<NoteBloc>().add(NoteDelete(n.localId));
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status == 'DONE' ? Colors.green
        : status == 'IN_PROGRESS' ? Colors.blue : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
