import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/settings_service.dart';

class SettingsState extends Equatable {
  final String defaultStatus;
  final ThemeMode themeMode;
  final int accentIndex;

  const SettingsState({
    this.defaultStatus = 'OPEN',
    this.themeMode = ThemeMode.light,
    this.accentIndex = 0,
  });

  AppThemePreset get currentTheme => SettingsService.themePresets[
        accentIndex >= 0 && accentIndex < SettingsService.themePresets.length
            ? accentIndex
            : 0];

  Color get primaryColor => currentTheme.primaryColor;
  Color get secondaryColor => currentTheme.secondaryColor;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  SettingsState copyWith({
    String? defaultStatus,
    ThemeMode? themeMode,
    int? accentIndex,
  }) {
    return SettingsState(
      defaultStatus: defaultStatus ?? this.defaultStatus,
      themeMode: themeMode ?? this.themeMode,
      accentIndex: accentIndex ?? this.accentIndex,
    );
  }

  @override
  List<Object?> get props => [defaultStatus, themeMode, accentIndex];
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

class SettingsToggleThemeMode extends SettingsEvent {}

class SettingsSetThemeMode extends SettingsEvent {
  final ThemeMode mode;
  SettingsSetThemeMode(this.mode);
  @override
  List<Object?> get props => [mode];
}

class SettingsChangeAccent extends SettingsEvent {
  final int index;
  SettingsChangeAccent(this.index);
  @override
  List<Object?> get props => [index];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService service;

  SettingsBloc(this.service) : super(const SettingsState()) {
    on<SettingsLoad>((e, emit) async {
      final status = await service.getDefaultStatus();
      final mode = await service.getThemeMode();
      final accent = await service.getAccentIndex();
      emit(state.copyWith(
        defaultStatus: status,
        themeMode: mode,
        accentIndex: accent,
      ));
    });

    on<SettingsChangeDefault>((e, emit) async {
      await service.setDefaultStatus(e.status);
      emit(state.copyWith(defaultStatus: e.status));
    });

    on<SettingsToggleThemeMode>((e, emit) async {
      final newMode =
          state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      await service.setThemeMode(newMode);
      emit(state.copyWith(themeMode: newMode));
    });

    on<SettingsSetThemeMode>((e, emit) async {
      await service.setThemeMode(e.mode);
      emit(state.copyWith(themeMode: e.mode));
    });

    on<SettingsChangeAccent>((e, emit) async {
      await service.setAccentIndex(e.index);
      emit(state.copyWith(accentIndex: e.index));
    });
  }
}
