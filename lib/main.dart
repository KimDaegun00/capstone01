import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nav_screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:capstone/config/env_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'detail_screens/login_screen.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'detail_screens/password_reset_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 앱 초기화
  await dotenv.load(fileName: '.env'); // .env 파일 로드
  usePathUrlStrategy(); // pc에서 딥링크를 사용하기 위해 필수

  // Supabase 초기화
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey
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
      surface: Colors.white,
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
      surface: Color(0xFF1E1E1E),
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
            return MaterialApp.router(
              title: "맘편한AI",
              routerConfig: _router,
              theme: _lightTheme,
              darkTheme: _darkTheme,
              themeMode: currentMode,
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/reset-password',
      builder: (context, state){
        print('�� /reset-password 라우트 실행됨!');
        print('🔑 토큰: ${state.uri.queryParameters['token']}');
        print('📝 타입: ${state.uri.queryParameters['type']}');
        
        final token = state.uri.queryParameters['token'];
        final type = state.uri.queryParameters['type'];
        return PasswordResetPage(token: token, type: type);
      },
    ),
    GoRoute(
      path: '/',
      builder: (context, state){
        return AuthWrapper();
      },
    ),
  ],
);

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) {
            // 로그인된 상태 - 데모 화면으로 이동
            return const MainScreen();
          }
        }
        
        // 로그인되지 않은 상태 - 로그인 화면으로 이동
        return const LoginScreen();
      },
    );
  }
}
