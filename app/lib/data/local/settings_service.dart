import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemePreset {
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;

  const AppThemePreset({
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
  });
}

/// Local-only settings. "Default Note Status", Theme Mode, and Accent Themes
/// persist across restarts and are stored locally on device.
class SettingsService {
  static const _statusKey = 'default_note_status';
  static const _themeModeKey = 'app_theme_mode';
  static const _accentKey = 'app_accent_color_index';

  static const statuses = ['OPEN', 'IN_PROGRESS', 'DONE'];

  static const List<AppThemePreset> themePresets = [
    AppThemePreset(
      name: 'Indigo Tech',
      description: 'Blueprint Indigo & Cyan (Default)',
      primaryColor: Color(0xFF4F46E5),
      secondaryColor: Color(0xFF06B6D4),
      icon: Icons.architecture_rounded,
    ),
    AppThemePreset(
      name: 'Emerald Field',
      description: 'Renewable energy, forestry & environmental',
      primaryColor: Color(0xFF059669),
      secondaryColor: Color(0xFF10B981),
      icon: Icons.eco_rounded,
    ),
    AppThemePreset(
      name: 'Ocean Marine',
      description: 'Harbor, bridge & civil infrastructure',
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF38BDF8),
      icon: Icons.water_drop_rounded,
    ),
    AppThemePreset(
      name: 'Safety Amber',
      description: 'High-visibility construction & industrial',
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFFF59E0B),
      icon: Icons.warning_amber_rounded,
    ),
    AppThemePreset(
      name: 'Electric Violet',
      description: 'Robotics, power grid & high-voltage telemetry',
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFFA855F7),
      icon: Icons.bolt_rounded,
    ),
  ];

  Future<String> getDefaultStatus() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_statusKey) ?? 'OPEN';
  }

  Future<void> setDefaultStatus(String status) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_statusKey, status);
  }

  Future<ThemeMode> getThemeMode() async {
    final p = await SharedPreferences.getInstance();
    final modeStr = p.getString(_themeModeKey) ?? 'light';
    switch (modeStr) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final p = await SharedPreferences.getInstance();
    final modeStr = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.system
            ? 'system'
            : 'light';
    await p.setString(_themeModeKey, modeStr);
  }

  Future<int> getAccentIndex() async {
    final p = await SharedPreferences.getInstance();
    final idx = p.getInt(_accentKey) ?? 0;
    if (idx < 0 || idx >= themePresets.length) return 0;
    return idx;
  }

  Future<void> setAccentIndex(int index) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_accentKey, index);
  }
}
