import 'package:flutter/material.dart';
import 'package:capstone/main.dart'; // tr(), langNotifier
import 'package:capstone/nav_screens/ai_screen.dart';
import 'package:capstone/nav_screens/profile_screen.dart';
import 'package:capstone/nav_screens/settingsScreen.dart';
import 'package:capstone/detail_screens/benefit_screen.dart';
import 'package:capstone/detail_screens/checklist_screen.dart';
import 'package:capstone/detail_screens/info_screen.dart';
import 'package:capstone/detail_screens/nearby_screen.dart';
import 'package:capstone/nav_screens/InfoInputMainScreen.dart';
import 'main_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int? currentWeek;

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Widget _getBody() {
    switch (_selectedIndex) {
      case 1:
        return ProfileScreen();          // ⬅ const 제거
      case 2:
        return SettingsScreen();         // ⬅ const 제거
      default:
        return MainGridMenu(
          currentWeek: currentWeek,
          onWeekUpdated: (int week) {
            setState(() {
              currentWeek = week;
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        title: Text(tr('메인화면', 'Home')),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      )
          : null,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _getBody(),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

/* ───────────────────────── MainGridMenu ───────────────────────── */

class MainGridMenu extends StatelessWidget {
  final int? currentWeek;
  final void Function(int)? onWeekUpdated;

  const MainGridMenu({
    Key? key,
    required this.currentWeek,
    required this.onWeekUpdated,
  }) : super(key: key);

  List<MenuItem> _getMenuItems(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      MenuItem(
        title: tr('혜택 안내', 'Benefits'),
        icon: Icons.card_giftcard,
        gradient: isDark
            ? [const Color(0xFFB04040), const Color(0xFF802020)]
            : [const Color(0xFFFF8C8C), const Color(0xFFFFB6B6)],
        screen: PolicyRecommendationPage(),         // ⬅ const 제거
      ),
      MenuItem(
        title: tr('주변 시설', 'Nearby'),
        icon: Icons.place,
        gradient: isDark
            ? [const Color(0xFFB28F3D), const Color(0xFF806E2A)]
            : [const Color(0xFFFFD57E), const Color(0xFFFFE1A8)],
        screen: NearbyScreen(),          // ⬅ const 제거
      ),
      MenuItem(
        title: tr('체크리스트', 'Checklist'),
        icon: Icons.check_circle_outline,
        gradient: isDark
            ? [const Color(0xFF4C7F8F), const Color(0xFF3A5D6B)]
            : [const Color(0xFF88D8E8), const Color(0xFFA8D5FF)],
        screen: ChecklistScreen(),       // ⬅ const 제거
      ),
      MenuItem(
        title: tr('맞춤 정보', 'Custom Info'),
        icon: Icons.info_outline,
        gradient: isDark
            ? [const Color(0xFF5A8B63), const Color(0xFF3B5C39)]
            : [const Color(0xFFA3EFA9), const Color(0xFFC1E1C1)],
        screen: InfoScreen(),            // ⬅ const 제거
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getMenuItems(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    const lightBg = Color(0xFFF5F0FF);
    const lightFg = Color(0xFF7F52FF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          /* ===== 그리드 메뉴 ===== */
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
              children:
              items.map((item) => _buildGridItem(item, context)).toList(),
            ),
          ),

          /* ===== 임신일 수 표시 ===== */
          if (currentWeek != null && currentWeek! > 0) ...[
            const SizedBox(height: 12),
            Text(
              '${currentWeek}일',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],

          const SizedBox(height: 16),

          /* ===== AI와 대화하기 버튼 ===== */
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AiScreen()), // ⬅ const 제거
              ),
              child: Text(tr('AI와 대화하기', 'Chat with AI'),
                  style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? primary : lightBg,
                foregroundColor: isDark ? Colors.white : lightFg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          /* ===== 정보 입력하기 버튼 ===== */
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => InfoInputMainScreen()), // ⬅ const 제거
                );
                if (result != null && onWeekUpdated != null) {
                  onWeekUpdated!(result['dayCount'] as int);
                }
              },
              child: Text(tr('정보 입력하기', 'Input Info'),
                  style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? primary : lightBg,
                foregroundColor: isDark ? Colors.white : lightFg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ───────────────────── MenuItem 카드 ───────────────────── */
  Widget _buildGridItem(MenuItem item, BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
        splashColor: Colors.white24,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: item.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final Widget screen;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.screen,
  });
}
