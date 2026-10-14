import 'package:shared_preferences/shared_preferences.dart';

/// Local-only settings. "Default Note Status" persists across restarts
/// and is NEVER synced with the backend (per task spec).
class SettingsService {
  static const _key = 'default_note_status';
  static const statuses = ['OPEN', 'IN_PROGRESS', 'DONE'];

  Future<String> getDefaultStatus() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_key) ?? 'OPEN';
  }

  Future<void> setDefaultStatus(String status) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, status);
  }
}
