import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone/main.dart';

class OptionScreen extends StatelessWidget {
  const OptionScreen({super.key});

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: MyApp.themeNotifier,
            builder: (context, currentMode, _) {
              return SwitchListTile(
                title: Text('다크모드'),
                secondary: Icon(Icons.dark_mode),
                value: currentMode == ThemeMode.dark,
                onChanged: (bool isDark) {
                  MyApp.themeNotifier.value =
                  isDark ? ThemeMode.dark : ThemeMode.light;
                  _saveTheme(isDark);
                },
              );
            },
          ),
          // 다른 설정 항목들 추가 가능
        ],
      ),
    );
  }
}
