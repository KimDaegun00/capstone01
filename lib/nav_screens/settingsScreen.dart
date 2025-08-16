import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone/main.dart'; // tr, themeNotifier, langNotifier
import 'package:capstone/nav_screens/feedback_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('설정', 'Settings')),
        // 라이트/다크에 따라 자동으로 맞춰짐
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 🌙 다크모드 토글
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, _) {
              return SwitchListTile(
                title: Text(tr('다크모드', 'Dark Mode')),
                secondary: const Icon(Icons.dark_mode),
                value: currentMode == ThemeMode.dark,
                onChanged: (bool isDark) {
                  themeNotifier.value =
                  isDark ? ThemeMode.dark : ThemeMode.light;
                  _saveTheme(isDark);
                },
              );
            },
          ),

          // 🌐 영어로 보기 토글
          ValueListenableBuilder<bool>(
            valueListenable: langNotifier,
            builder: (context, isEnglish, _) {
              return SwitchListTile(
                title: Text(isEnglish ? '한국어로 보기' : '영어로 보기'),
                secondary: const Icon(Icons.language),
                value: isEnglish,
                onChanged: (bool newValue) {
                  langNotifier.value = newValue;
                },
              );
            },
          ),

          // ✉️ 피드백 보내기
          ListTile(
            leading: const Icon(Icons.feedback),
            title: Text(tr('피드백 보내기', 'Send Feedback')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
