import 'package:flutter/material.dart';

/// 하단 네비게이션 바 위젯
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
  });

  static const Color _backgroundColor = Color(0xFFFDEAE8); // 전체 배경
  static const Color _indicatorColor = Color(0xFFFCDADA); // 선택 배경
  static const Color _iconColor = Colors.black; // 공통 아이콘 색

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: NavigationBar(
        height: 64,
        elevation: 0,
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemTapped,
        backgroundColor: _backgroundColor,
        indicatorColor: _indicatorColor,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: _iconColor),
            selectedIcon: Icon(Icons.home_outlined, color: _iconColor),
            label: '메인',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: _iconColor),
            selectedIcon: Icon(Icons.person_outline, color: _iconColor),
            label: '프로필',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: _iconColor),
            selectedIcon: Icon(Icons.settings_outlined, color: _iconColor),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
