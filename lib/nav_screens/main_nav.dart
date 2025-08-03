import 'package:flutter/material.dart';
import 'package:capstone/main.dart'; // tr(), langNotifier 사용 위해 필요

/// 하단 네비게이션 바 위젯
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
    isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFDEAE8);
    final indicatorColor =
    isDark ? Colors.teal.shade700 : const Color(0xFFFCDADA);
    final iconColor = isDark ? Colors.white : Colors.black;

    return ValueListenableBuilder<bool>(
      valueListenable: langNotifier,
      builder: (context, isEnglish, _) {
        return Container(
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: NavigationBar(
            height: 64,
            elevation: 0,
            selectedIndex: selectedIndex,
            onDestinationSelected: onItemTapped,
            backgroundColor: backgroundColor,
            indicatorColor: indicatorColor,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: iconColor),
                selectedIcon: Icon(Icons.home_outlined, color: iconColor),
                label: tr('메인', 'Home'),
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: iconColor),
                selectedIcon: Icon(Icons.person_outline, color: iconColor),
                label: tr('프로필', 'Profile'),
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: iconColor),
                selectedIcon: Icon(Icons.settings_outlined, color: iconColor),
                label: tr('설정', 'Settings'),
              ),
            ],
          ),
        );
      },
    );
  }
}
