import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/customer.dart';
import '../../data/sync_repository.dart';

class CustomerState extends Equatable {
  final List<Customer> items;
  final bool syncing;
  final String? message;
  const CustomerState({this.items = const [], this.syncing = false, this.message});
  @override
  List<Object?> get props => [items, syncing, message];
}

abstract class CustomerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomersLoad extends CustomerEvent {}

class CustomerSave extends CustomerEvent {
  final String? localId;
  final String name;
  final String contactInfo;
  CustomerSave({this.localId, required this.name, required this.contactInfo});
}

class CustomerDelete extends CustomerEvent {
  final String localId;
  CustomerDelete(this.localId);
  @override
  List<Object?> get props => [localId];
}

class CustomersSync extends CustomerEvent {}

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final SyncRepository repo;
  CustomerBloc(this.repo) : super(const CustomerState()) {
    on<CustomersLoad>((e, emit) {
      emit(CustomerState(items: repo.local.getCustomers()));
    });
    on<CustomerSave>((e, emit) async {
      await repo.saveCustomer(localId: e.localId, name: e.name, contactInfo: e.contactInfo);
      add(CustomersSync());
      emit(CustomerState(items: repo.local.getCustomers()));
    });
    on<CustomerDelete>((e, emit) async {
      await repo.deleteCustomer(e.localId);
      add(CustomersSync());
      emit(CustomerState(items: repo.local.getCustomers()));
    });
    on<CustomersSync>((e, emit) async {
      emit(CustomerState(items: repo.local.getCustomers(), syncing: true));
      final msg = await repo.sync();
      emit(CustomerState(items: repo.local.getCustomers(), message: msg));
    });
  }
}
