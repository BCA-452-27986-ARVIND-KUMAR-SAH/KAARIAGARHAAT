import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader("App Settings"),
          _switchTile(
            "Push Notifications",
            "Get updates about orders and offers",
            _notificationsEnabled,
            (val) => setState(() => _notificationsEnabled = val),
          ),
          SwitchListTile(
            title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text("Enable dark theme for the app", style: TextStyle(fontSize: 12, color: Colors.grey)),
            value: themeProvider.isDarkMode,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              themeProvider.toggleTheme();
            },
            contentPadding: EdgeInsets.zero,
          ),
          _languageTile(),
          
          const SizedBox(height: 32),
          _sectionHeader("Account & Privacy"),
          _linkTile("Privacy Policy", Icons.privacy_tip_outlined),
          _linkTile("Terms & Conditions", Icons.description_outlined),
          _linkTile("Delete Account", Icons.delete_forever_outlined, color: AppColors.accent),
          
          const SizedBox(height: 32),
          _sectionHeader("App Info"),
          const ListTile(
            title: Text("Version"),
            trailing: Text("1.0.0", style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _languageTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text("Language", style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: const Text("Select your preferred language", style: TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        underline: const SizedBox(),
        items: ['English', 'Hindi', 'Maithili', 'Bengali'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          );
        }).toList(),
        onChanged: (val) {
          setState(() => _selectedLanguage = val!);
        },
      ),
    );
  }

  Widget _linkTile(String title, IconData icon, {Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.textDark),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textDark, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}
