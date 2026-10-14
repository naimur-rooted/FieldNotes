import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/field_note.dart';
import '../../data/sync_repository.dart';

class NoteState extends Equatable {
  final List<FieldNote> items;
  final String query;
  final String statusFilter;
  final String? siteFilter;
  final String? message;
  const NoteState({this.items = const [], this.query = '', this.statusFilter = '', this.siteFilter, this.message});
  @override
  List<Object?> get props => [items, query, statusFilter, siteFilter, message];
}

abstract class NoteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesLoad extends NoteEvent {
  final String query;
  final String statusFilter;
  final String? siteFilter;
  NotesLoad({this.query = '', this.statusFilter = '', this.siteFilter});
}

class NoteSave extends NoteEvent {
  final String? localId;
  final String siteLocalId;
  final String title;
  final String description;
  final String location;
  final DateTime? dateTime;
  final String status;
  final String? photoLocalPath;
  NoteSave({this.localId, required this.siteLocalId, required this.title,
    required this.description, required this.location, this.dateTime,
    required this.status, this.photoLocalPath});
}

class NoteDelete extends NoteEvent {
  final String localId;
  NoteDelete(this.localId);
  @override
  List<Object?> get props => [localId];
}

class NotesSync extends NoteEvent {}

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final SyncRepository repo;
  NoteBloc(this.repo) : super(const NoteState()) {
    List<FieldNote> filtered(String q, String st, String? site) =>
        repo.local.getNotes(query: q, status: st, siteLocalId: site);
    on<NotesLoad>((e, emit) {
      emit(NoteState(items: filtered(e.query, e.statusFilter, e.siteFilter),
          query: e.query, statusFilter: e.statusFilter, siteFilter: e.siteFilter));
    });
    on<NoteSave>((e, emit) async {
      await repo.saveNote(localId: e.localId, siteLocalId: e.siteLocalId,
          title: e.title, description: e.description, location: e.location,
          dateTime: e.dateTime, status: e.status, photoLocalPath: e.photoLocalPath);
      add(NotesSync());
      emit(NoteState(items: filtered(state.query, state.statusFilter, state.siteFilter),
          query: state.query, statusFilter: state.statusFilter, siteFilter: state.siteFilter));
    });
    on<NoteDelete>((e, emit) async {
      await repo.deleteNote(e.localId);
      add(NotesSync());
      emit(NoteState(items: filtered(state.query, state.statusFilter, state.siteFilter),
          query: state.query, statusFilter: state.statusFilter, siteFilter: state.siteFilter));
    });
    on<NotesSync>((e, emit) async {
      final msg = await repo.sync();
      emit(NoteState(items: filtered(state.query, state.statusFilter, state.siteFilter),
          query: state.query, statusFilter: state.statusFilter,
          siteFilter: state.siteFilter, message: msg));
    });
  }
}
