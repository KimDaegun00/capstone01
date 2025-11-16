// lib/nav_screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:capstone/main.dart'; // tr(), langNotifier
import 'package:capstone/nav_screens/profile_screen.dart';
import 'package:capstone/nav_screens/settingsScreen.dart';
import 'package:capstone/detail_screens/benefit_screen.dart';
import 'package:capstone/detail_screens/checklist_screen.dart';
import 'package:capstone/detail_screens/info_screen.dart';
import 'package:capstone/detail_screens/nearby_screen.dart';
import 'package:capstone/detail_screens/bookmark_screen.dart';
import 'main_nav.dart';
import '../services/auth_service.dart';

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
        return ProfileScreen();
      case 2:
        return SettingsScreen();
      default:
        return MainGridMenu();
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;



    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        title: Text(tr('메인화면', 'Home')),
        elevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: '로그아웃',
          ),
        ],
      )
          : null,
      backgroundColor: cs.surface,
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

  const MainGridMenu({super.key});

  List<MenuItem> _getMenuItems(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 정책 추천: 연분홍/코랄 계열
    final policy = isDark
        ? const [Color(0xFFB04040), Color(0xFF802020)]
        : const [Color(0xFFFF8C8C), Color(0xFFFFB6B6)];

    final nearby = isDark
        ? const [Color(0xFFB1722E), Color(0xFFD09456)]
        : const [Color(0xFFFFB86B), Color(0xFFFFD29D)];

    final checklist = isDark
        ? const [Color(0xFF2F8F8A), Color(0xFF4FB3AB)]
        : const [Color(0xFF69D6CC), Color(0xFF9BE6DF)];

    final health = isDark
        ? const [Color(0xFF2C6E49), Color(0xFF3E8B61)]
        : const [Color(0xFF86D4A4), Color(0xFFC2E9D1)];

    return [
      MenuItem(
        title: '정책 추천',
        icon: Icons.card_giftcard,
        gradient: policy,
        screen: PolicyRecommendationPage(),
      ),
      MenuItem(
        title: '주변 시설',
        icon: Icons.place,
        gradient: nearby,
        screen: NearbyScreen(),
      ),
      MenuItem(
        title: '체크리스트',
        icon: Icons.check_circle_outline,
        gradient: checklist,
        screen: ChecklistScreen(),
      ),
      MenuItem(
        title: '건강/육아 정보',
        icon: Icons.info,
        gradient: health,
        screen: HealthInfoList(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getMenuItems(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final spacing = 14.0;
    final primaryBg = isDark ? cs.primary : const Color(0xFFECE8FF);
    final primaryFg = isDark ? Colors.white : const Color(0xFF6B5CFF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // ===== 2×2 버튼 그리드 =====
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildGridItem(items[0], context)),
                      SizedBox(width: spacing),
                      Expanded(child: _buildGridItem(items[1], context)),
                    ],
                  ),
                ),
                SizedBox(height: spacing),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildGridItem(items[2], context)),
                      SizedBox(width: spacing),
                      Expanded(child: _buildGridItem(items[3], context)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const SizedBox(height: 12),

          /* 정책 즐겨찾기 버튼 */
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bookmark),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookmarkScreen()),
              ),
              label: Text(
                tr('정책 즐겨찾기', 'Bookmark Policies'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBg,
                foregroundColor: primaryFg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /* ───────────────────── MenuItem 카드 ───────────────────── */
  Widget _buildGridItem(MenuItem item, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
    isDark ? Colors.white.withOpacity(.10) : Colors.black.withOpacity(.06);
    final shadowColor =
    isDark ? Colors.black.withOpacity(.35) : Colors.black.withOpacity(.08);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.screen),
        ),
        splashColor: Colors.white24,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: item.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘 캡슐
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Icon(item.icon, size: 28, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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
