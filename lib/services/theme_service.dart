import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테마 관리 서비스
class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  /// 테마 모드 저장
  static Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      debugPrint('❌ 테마 저장 실패: $e');
    }
  }
  
  /// 테마 모드 로드
  static Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey);
      
      if (themeString == null) {
        return ThemeMode.light; // 기본값: 라이트 모드
      }
      
      // 문자열을 ThemeMode로 변환
      switch (themeString) {
        case 'ThemeMode.light':
          return ThemeMode.light;
        case 'ThemeMode.dark':
          return ThemeMode.dark;
        case 'ThemeMode.system':
          // 기존에 시스템 모드로 저장된 경우 라이트 모드로 변환
          return ThemeMode.light;
        default:
          return ThemeMode.light; // 기본값: 라이트 모드
      }
    } catch (e) {
      debugPrint('❌ 테마 로드 실패: $e');
      return ThemeMode.light; // 오류 시 라이트 모드
    }
  }
  
}
