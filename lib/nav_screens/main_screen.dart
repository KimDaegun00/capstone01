import 'package:flutter/material.dart';
import 'package:capstone/nav_screens/main_nav.dart';
import 'package:capstone/nav_screens/calendar_screen.dart';
import 'package:capstone/nav_screens/profile_screen.dart';
import 'package:capstone/nav_screens/qna_screen.dart';
import 'package:capstone/detail_screens/benefit_screen.dart';
import 'package:capstone/detail_screens/checklist_screen.dart';
import 'package:capstone/detail_screens/info_screen.dart';
import 'package:capstone/detail_screens/nearby_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 1:
        return ProfileScreen();
      default:
        return const MainGridMenu();
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
          : null, // 👉 다른 화면일 땐 AppBar 없앰
      backgroundColor: const Color(0xFFF7F5F4),
      body: _getBody(),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}


/// 메인 화면 2x2 그리드 메뉴
class MainGridMenu extends StatelessWidget {
  const MainGridMenu({Key? key}) : super(key: key);



  static List<MenuItem> items = [
    MenuItem(
      title: '혜택 안내',
      icon: Icons.card_giftcard,
      gradient: [Color(0xFFFF8C8C), Color(0xFFFFB6B6)],
      screen: BenefitScreen(), // BenefitScreen으로 이동
    ),
    MenuItem(
      title: '주변 시설',
      icon: Icons.place,
      gradient: [Color(0xFFFFD57E), Color(0xFFFFE1A8)],
      screen: NearbyScreen(),
    ),
    MenuItem(
      title: '체크리스트',
      icon: Icons.check_circle_outline,
      gradient: [Color(0xFF88D8E8), Color(0xFFA8D5FF)],
      screen: ChecklistScreen(),
    ),
    MenuItem(
      title: '맞춤 정보',
      icon: Icons.info_outline,
      gradient: [Color(0xFFA3EFA9), Color(0xFFC1E1C1)],
      screen: InfoScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
        children: items.map((item) => _buildGridItem(item, context)).toList(),
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
          // 해당 화면으로 이동
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


/// 메뉴 아이템 모델
class MenuItem {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final Widget screen;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.screen, //스크린 이동 파라미터
  });
}
