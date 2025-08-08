import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nav_screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qzkdirgocngvylcowfnj.supabase.co',
    anonKey: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF6a2RpcmdvY25ndnlsY293Zm5qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NDExNDIsImV4cCI6MjA2OTAxNzE0Mn0.WRrFY4wBpdMfOzKKpA1jDmEhTBx8EZBO0Eqzh9uIs_A',
  );

  runApp(const MyApp());
}

/// ────────────────────────────────
///  전역 Notifier들
/// ────────────────────────────────

/// 다크모드 전역 상태
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

/// 언어 상태: false = 한글, true = 영어
final ValueNotifier<bool> langNotifier = ValueNotifier(false);

/// 문자열 전환 헬퍼
String tr(String ko, String en) => langNotifier.value ? en : ko;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 라이트 테마 정의
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
      background: Color(0xFFF7F5F4),
      surface: Colors.white,
      onBackground: Colors.black,
      onSurface: Colors.black,
    ),
  );

  /// 다크 테마 정의
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
  );

  /// 앱 시작 시 SharedPreferences로 다크모드 상태 복원
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// MaterialApp 구성
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: langNotifier, // 언어 변경 시 앱 전체 리빌드
      builder: (_, __, ___) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, _) {
            return MaterialApp(
              title: 'Mother Compass',
              debugShowCheckedModeBanner: false,
              theme: _lightTheme,
              darkTheme: _darkTheme,
              themeMode: currentMode,
              home: const MainScreen(), // 기존 루트 화면
            );
          },
        );
      },
    );
  }
}
