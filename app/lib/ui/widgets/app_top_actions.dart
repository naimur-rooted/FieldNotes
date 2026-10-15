import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';

class AppTopActions extends StatelessWidget {
  final Widget? leadingAction;

  const AppTopActions({super.key, this.leadingAction});

  static void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of Field Notes? All offline data is safely preserved in Hive local storage.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogout());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingAction != null) ...[
              leadingAction!,
              const SizedBox(width: 4),
            ],

            // Light / Dark Mode Toggle
            IconButton.filledTonal(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: anim,
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(isDark),
                  size: 20,
                  color: isDark ? const Color(0xFFFBBF24) : settings.primaryColor,
                ),
              ),
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: () {
                context.read<SettingsBloc>().add(SettingsToggleThemeMode());
              },
            ),
            const SizedBox(width: 4),

            // Fixed Logout Button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA),
                    width: 0.8,
                  ),
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
              ),
              tooltip: 'Sign Out',
              onPressed: () => showLogoutConfirmation(context),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }
}
