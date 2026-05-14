import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSurface : AppTheme.surface,

      appBar: AppBar(title: const Text("Settings"), elevation: 0),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider),
            ),

            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryLight,
                  child: const Icon(Icons.person, color: AppTheme.primary, size: 30),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Volunteer User", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),

                      SizedBox(height: 4),

                      Text("volunteer@test.com", style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),

                Icon(Icons.edit_outlined, color: AppTheme.textLight),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text("Preferences", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider),
            ),

            child: SwitchListTile(
              value: darkMode,

              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });

                VolunteerApp.of(context)?.toggleTheme(value);
              },

              secondary: const Icon(Icons.dark_mode_outlined),

              title: const Text("Dark Mode"),

              subtitle: const Text("Enable dark appearance"),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider),
            ),

            child: SwitchListTile(
              value: notifications,

              onChanged: (value) {
                setState(() {
                  notifications = value;
                });
              },

              secondary: const Icon(Icons.notifications_none),

              title: const Text("Notifications"),

              subtitle: const Text("Receive volunteer updates"),
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),

            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },

            icon: const Icon(Icons.logout),

            label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
