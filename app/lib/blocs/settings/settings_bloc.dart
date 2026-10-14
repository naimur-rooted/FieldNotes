import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/settings_service.dart';

class SettingsState extends Equatable {
  final String defaultStatus;
  const SettingsState({this.defaultStatus = 'OPEN'});
  @override
  List<Object?> get props => [defaultStatus];
}

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SettingsLoad extends SettingsEvent {}

class SettingsChangeDefault extends SettingsEvent {
  final String status;
  SettingsChangeDefault(this.status);
  @override
  List<Object?> get props => [status];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService service;
  SettingsBloc(this.service) : super(const SettingsState()) {
    on<SettingsLoad>((e, emit) async {
      emit(SettingsState(defaultStatus: await service.getDefaultStatus()));
    });
    on<SettingsChangeDefault>((e, emit) async {
      await service.setDefaultStatus(e.status);
      emit(SettingsState(defaultStatus: e.status));
    });
  }
}
