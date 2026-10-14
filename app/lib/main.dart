import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/customers/customer_bloc.dart';
import 'blocs/notes/note_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/sites/site_bloc.dart';
import 'data/local/local_store.dart';
import 'data/local/settings_service.dart';
import 'data/remote/api_service.dart';
import 'data/sync_repository.dart';
import 'ui/auth_page.dart';
import 'ui/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final local = await LocalStore.init();
  final api = ApiService();
  await api.loadToken();
  final repo = SyncRepository(local, api);
  final settings = SettingsService();
  runApp(FieldNotesApp(local: local, api: api, repo: repo, settings: settings));
}

class FieldNotesApp extends StatelessWidget {
  final LocalStore local;
  final ApiService api;
  final SyncRepository repo;
  final SettingsService settings;
  const FieldNotesApp(
      {super.key, required this.local, required this.api, required this.repo, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(api, repo)..add(AuthCheck())),
        BlocProvider(create: (_) => CustomerBloc(repo)),
        BlocProvider(create: (_) => SiteBloc(repo)),
        BlocProvider(create: (_) => NoteBloc(repo)),
        BlocProvider(create: (_) => SettingsBloc(settings)..add(SettingsLoad())),
      ],
      child: MaterialApp(
        title: 'Field Notes',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.checking) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return state.loggedIn ? const HomePage() : const AuthPage();
          },
        ),
      ),
    );
  }
}

