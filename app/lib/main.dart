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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F46E5),
            primary: const Color(0xFF4F46E5),
            secondary: const Color(0xFF0EA5E9),
            tertiary: const Color(0xFF10B981),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1E293B),
            elevation: 0,
            centerTitle: false,
            scrolledUnderElevation: 1,
            titleTextStyle: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.8),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFEEF2FF),
            elevation: 3,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5));
              }
              return const TextStyle(fontSize: 12, color: Color(0xFF64748B));
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFF4F46E5));
              }
              return const IconThemeData(color: Color(0xFF64748B));
            }),
          ),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.checking) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                ),
              );
            }
            return state.loggedIn ? const HomePage() : const AuthPage();
          },
        ),
      ),
    );
  }
}

