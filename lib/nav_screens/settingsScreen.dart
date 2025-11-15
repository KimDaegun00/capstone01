import 'package:flutter/material.dart';
import 'package:capstone/main.dart'; // tr, themeNotifier, langNotifier
import 'package:capstone/nav_screens/feedback_screen.dart';
import 'package:capstone/services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              // 시스템 모드가 선택되어 있으면 라이트 모드로 변환
              if (currentMode == ThemeMode.system) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  themeNotifier.value = ThemeMode.light;
                  ThemeService.saveThemeMode(ThemeMode.light);
                });
              }
              
              final isDark = currentMode == ThemeMode.dark;
              
              return SwitchListTile(
                title: Text(tr('다크모드', 'Dark Mode')),
                secondary: const Icon(Icons.dark_mode),
                value: isDark,
                onChanged: (bool value) {
                  final newMode = value ? ThemeMode.dark : ThemeMode.light;
                  themeNotifier.value = newMode;
                  ThemeService.saveThemeMode(newMode);
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
