import 'package:capstone/nav_screens/ai_screen.dart';
import 'package:capstone/nav_screens/option_screen.dart';
import 'package:capstone/nav_screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:capstone/detail_screens/benefit_screen.dart';
import 'package:capstone/detail_screens/checklist_screen.dart';
import 'package:capstone/detail_screens/info_screen.dart';
import 'package:capstone/detail_screens/nearby_screen.dart';
import 'package:capstone/nav_screens/InfoInputMainScreen.dart';

import 'main_nav.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int? currentWeek;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 1:
        return ProfileScreen();
      case 2:
        return OptionScreen();
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
        title: const Text('메인화면'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      )
          : null,
      backgroundColor: const Color(0xFFF7F5F4),
      body: _getBody(),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class MainGridMenu extends StatelessWidget {
  final int? currentWeek;
  final void Function(int)? onWeekUpdated;

  const MainGridMenu({
    Key? key,
    required this.currentWeek,
    required this.onWeekUpdated,
  }) : super(key: key);

  List<MenuItem> _getMenuItems(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      MenuItem(
        title: '혜택 안내',
        icon: Icons.card_giftcard,
        gradient: isDark
            ? [Color(0xFFB04040), Color(0xFF802020)]
            : [Color(0xFFFF8C8C), Color(0xFFFFB6B6)],
        screen: BenefitScreen(),
      ),
      MenuItem(
        title: '주변 시설',
        icon: Icons.place,
        gradient: isDark
            ? [Color(0xFFB28F3D), Color(0xFF806E2A)]
            : [Color(0xFFFFD57E), Color(0xFFFFE1A8)],
        screen: NearbyScreen(),
      ),
      MenuItem(
        title: '체크리스트',
        icon: Icons.check_circle_outline,
        gradient: isDark
            ? [Color(0xFF4C7F8F), Color(0xFF3A5D6B)]
            : [Color(0xFF88D8E8), Color(0xFFA8D5FF)],
        screen: ChecklistScreen(),
      ),
      MenuItem(
        title: '맞춤 정보',
        icon: Icons.info_outline,
        gradient: isDark
            ? [Color(0xFF5A8B63), Color(0xFF3B5C39)]
            : [Color(0xFFA3EFA9), Color(0xFFC1E1C1)],
        screen: InfoScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getMenuItems(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
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
          if (currentWeek != null && currentWeek! > 0) ...[
            SizedBox(height: 12),
            Text(
              '${currentWeek}일',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AiScreen()),
                );
              },
              child: Text('AI와 대화하기', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.teal[700] : null,
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(builder: (context) => InfoInputMainScreen()),
                );

                if (result != null && onWeekUpdated != null) {
                  final int dayCount = result['dayCount'] as int;
                  onWeekUpdated!(dayCount);
                }
              },
              child: Text('정보 입력하기', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.teal[700] : null,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGridItem(MenuItem item, BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.screen),
          );
        },
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
