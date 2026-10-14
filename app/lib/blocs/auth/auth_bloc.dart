import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/remote/api_service.dart';
import '../../data/sync_repository.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheck extends AuthEvent {}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  AuthLogin(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthRegister extends AuthEvent {
  final String name;
  final String email;
  final String password;
  AuthRegister(this.name, this.email, this.password);
  @override
  List<Object?> get props => [name, email, password];
}

class AuthLogout extends AuthEvent {}

class AuthState extends Equatable {
  final bool checking;
  final bool loggedIn;
  final bool loading;
  final String? error;
  const AuthState({this.checking = true, this.loggedIn = false, this.loading = false, this.error});
  AuthState copyWith({bool? checking, bool? loggedIn, bool? loading, String? error}) =>
      AuthState(checking: checking ?? this.checking, loggedIn: loggedIn ?? this.loggedIn,
          loading: loading ?? this.loading, error: error);
  @override
  List<Object?> get props => [checking, loggedIn, loading, error];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService api;
  final SyncRepository repo;
  AuthBloc(this.api, this.repo) : super(const AuthState()) {
    on<AuthCheck>((e, emit) async {
      await api.loadToken();
      emit(state.copyWith(checking: false, loggedIn: api.isLoggedIn));
      if (api.isLoggedIn) {
        try {
          await repo.pull();
        } catch (_) {}
      }
    });
    on<AuthLogin>((e, emit) async {
      emit(state.copyWith(loading: true, error: null));
      try {
        final j = await api.login(e.email, e.password);
        await api.saveAuth(j['token'] as String, (j['userId'] as num).toInt(),
            j['name'] as String, j['email'] as String);
        try {
          await repo.pull();
        } catch (_) {}
        emit(state.copyWith(loading: false, loggedIn: true));
      } catch (err) {
        emit(state.copyWith(loading: false, error: err.toString().replaceFirst('Exception: ', '')));
      }
    });
    on<AuthRegister>((e, emit) async {
      emit(state.copyWith(loading: true, error: null));
      try {
        final j = await api.register(e.name, e.email, e.password);
        await api.saveAuth(j['token'] as String, (j['userId'] as num).toInt(),
            j['name'] as String, j['email'] as String);
        emit(state.copyWith(loading: false, loggedIn: true));
      } catch (err) {
        emit(state.copyWith(loading: false, error: err.toString().replaceFirst('Exception: ', '')));
      }
    });
    on<AuthLogout>((e, emit) async {
      await api.clearAuth();
      await repo.local.clearAll();
      emit(state.copyWith(loggedIn: false));
    });
  }
}
