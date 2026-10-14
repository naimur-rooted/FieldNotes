import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import '../data/local/settings_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthBloc>().add(AuthLogout())),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Default Note Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Used automatically for new notes. Saved on this device only.',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              for (final s in SettingsService.statuses)
                ListTile(
                  title: Text(s),
                  trailing: state.defaultStatus == s
                      ? const Icon(Icons.check_circle, color: Colors.teal)
                      : const Icon(Icons.circle_outlined),
                  onTap: () => context
                      .read<SettingsBloc>()
                      .add(SettingsChangeDefault(s)),
                ),
              const Divider(height: 32),
              const Text('This setting never syncs with the backend (per spec).',
                  style: TextStyle(color: Colors.grey)),
            ],
          );
        },
      ),
    );
  }
}

