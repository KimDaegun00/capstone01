// lib/nav_screens/main_screen.dart
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
  final int? currentWeek;
  final void Function(int)? onWeekUpdated;

  const MainGridMenu({
    super.key,
    required this.currentWeek,
    required this.onWeekUpdated,
  });

  List<MenuItem> _getMenuItems(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 정책 추천: 원래 쓰던 연분홍/코랄 계열로 복구
    final policy = isDark
        ? const [Color(0xFFB04040), Color(0xFF802020)]
        : const [Color(0xFFFF8C8C), Color(0xFFFFB6B6)];

    // 나머지는 톤온톤 트렌디 팔레트 유지
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
      // ⚠️ 순서 그대로 유지
      MenuItem(
        title: tr('정책 추천', 'Benefits'),
        icon: Icons.card_giftcard,
        gradient: policy,
        screen: PolicyRecommendationPage(),
      ),
      MenuItem(
        title: tr('주변 시설', 'Nearby'),
        icon: Icons.place,
        gradient: nearby,
        screen: NearbyScreen(),
      ),
      MenuItem(
        title: tr('체크리스트', 'Checklist'),
        icon: Icons.check_circle_outline, // 메인 아이콘은 원형 유지
        gradient: checklist,
        screen: ChecklistScreen(),
      ),
      MenuItem(
        title: tr('건강/육아 정보', 'Custom Info'),
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

    // 버튼 톤
    final primaryBg = isDark ? cs.primary : const Color(0xFFECE8FF);
    final primaryFg = isDark ? Colors.white : const Color(0xFF6B5CFF);
    final secondaryBg = isDark ? cs.surfaceContainerHighest : const Color(0xFFF4F6F8);
    final secondaryFg = isDark ? cs.onSurface : const Color(0xFF3C3F44);
    final secondaryBorder =
    isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          /* ===== 2×2 그리드 메뉴 (순서 동일) ===== */
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1,
              children:
              items.map((item) => _buildGridItem(item, context)).toList(),
            ),
          ),

          /* ===== 임신일 수 표시(칩) ===== */
          if (currentWeek != null && currentWeek! > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(.10)
                      : Colors.black.withOpacity(.05),
                ),
              ),
              child: Text(
                '$currentWeek일',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          /* ===== AI와 대화하기 (Primary Tonal) ===== */
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.smart_toy),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AiScreen()),
              ),
              label: Text(
                tr('AI와 대화하기', 'Chat with AI'),
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

          /* ===== 정보 입력하기 (Tonal/Outline) ===== */
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit_note),
              onPressed: () async {
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(builder: (_) => InfoInputMainScreen()),
                );
                if (result != null && onWeekUpdated != null) {
                  onWeekUpdated!(result['dayCount'] as int);
                }
              },
              label: Text(
                tr('정보 입력하기', 'Input Info'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryBg,
                foregroundColor: secondaryFg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: secondaryBorder, width: 1),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 카드 스타일: 그라데이션 + 얇은 보더 + 소프트 섀도우 + 아이콘 캡슐
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
                spreadRadius: 0,
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
