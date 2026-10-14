import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/site.dart';
import '../../data/sync_repository.dart';

class SiteState extends Equatable {
  final List<Site> items;
  final String? message;
  const SiteState({this.items = const [], this.message});
  @override
  List<Object?> get props => [items, message];
}

abstract class SiteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SitesLoad extends SiteEvent {
  final String? customerLocalId;
  SitesLoad({this.customerLocalId});
}

class SiteSave extends SiteEvent {
  final String? localId;
  final String customerLocalId;
  final String name;
  final String address;
  SiteSave({this.localId, required this.customerLocalId, required this.name, required this.address});
}

class SiteDelete extends SiteEvent {
  final String localId;
  SiteDelete(this.localId);
  @override
  List<Object?> get props => [localId];
}

class SitesSync extends SiteEvent {}

class SiteBloc extends Bloc<SiteEvent, SiteState> {
  final SyncRepository repo;
  String? _filter;
  SiteBloc(this.repo) : super(const SiteState()) {
    on<SitesLoad>((e, emit) {
      _filter = e.customerLocalId;
      emit(SiteState(items: repo.local.getSites(customerLocalId: _filter)));
    });
    on<SiteSave>((e, emit) async {
      await repo.saveSite(localId: e.localId, customerLocalId: e.customerLocalId, name: e.name, address: e.address);
      add(SitesSync());
      emit(SiteState(items: repo.local.getSites(customerLocalId: _filter)));
    });
    on<SiteDelete>((e, emit) async {
      await repo.deleteSite(e.localId);
      add(SitesSync());
      emit(SiteState(items: repo.local.getSites(customerLocalId: _filter)));
    });
    on<SitesSync>((e, emit) async {
      final msg = await repo.sync();
      emit(SiteState(items: repo.local.getSites(customerLocalId: _filter), message: msg));
    });
  }
}
