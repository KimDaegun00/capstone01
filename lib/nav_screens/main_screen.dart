import 'package:flutter/material.dart';
import 'package:capstone/nav_screens/main_nav.dart';
import 'package:capstone/nav_screens/calendar_screen.dart';
import 'package:capstone/nav_screens/profile_screen.dart';
import 'package:capstone/nav_screens/qna_screen.dart';

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
    setState(() {
      _selectedIndex = index;
    });
  }

  // 화면을 반환하는 함수
  Widget _getBody() {
    switch (_selectedIndex) {
      case 1:
        return CalendarScreen();
      case 2:
        return QnaScreen();
      case 3:
        return ProfileScreen();
      default:
        return Center(child: Text('메인화면'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('메인화면')),
      body: _getBody(), // 해당 인덱스에 맞는 화면을 보여줌
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
