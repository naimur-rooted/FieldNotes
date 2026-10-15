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

  const FieldNotesApp({
    super.key,
    required this.local,
    required this.api,
    required this.repo,
    required this.settings,
  });

  ThemeData _buildTheme(Color primary, Color secondary, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        tertiary: const Color(0xFF10B981),
        surface: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 1,
        shadowColor: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
              width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF334155).withValues(alpha: 0.45)
            : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? const Color(0xFF475569) : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        indicatorColor: primary.withValues(alpha: isDark ? 0.28 : 0.12),
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: primary);
          }
          return TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary);
          }
          return IconThemeData(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
        }),
      ),
    );
  }

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
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'Field Notes',
            debugShowCheckedModeBanner: false,
            themeMode: settingsState.themeMode,
            theme: _buildTheme(settingsState.primaryColor,
                settingsState.secondaryColor, Brightness.light),
            darkTheme: _buildTheme(settingsState.primaryColor,
                settingsState.secondaryColor, Brightness.dark),
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.checking) {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                          color: settingsState.primaryColor),
                    ),
                  );
                }
                return state.loggedIn ? const HomePage() : const AuthPage();
              },
            ),
          );
        },
      ),
    );
  }
}
