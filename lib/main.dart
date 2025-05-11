import 'package:flutter/material.dart';
import 'nav_screens/main_nav.dart';
import 'nav_screens/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      home: MainScreen(), // ← 앱 시작 시 이 화면을 보여줌!
    );
  }
}
