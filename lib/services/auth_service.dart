import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // 현재 유저 가져오기
  static User? get currentUser => _supabase.auth.currentUser;
  
  // 인증 상태 변화 스트림
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  // 회원가입
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userMetadata,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: userMetadata,
      );
      
      // if (response.user != null && response.user!.emailConfirmedAt == null) {
      //   // 이메일 확인 필요
      //   throw Exception('이메일을 확인해주세요.');
      // }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // 로그인
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // 로그아웃
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
  
  // 비밀번호 재설정
  static Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email, 
        redirectTo: 'http://localhost:3000/reset-password'
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // 유저 프로필 가져오기 (capstone_schema.유저 테이블에서)
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .schema('capstone_schema')
          .from('유저')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // 유저 프로필 업데이트 (capstone_schema.유저 테이블에서)
  static Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _supabase
          .schema('capstone_schema')
          .from('유저')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
  
  // 에러 메시지 변환
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return '이메일 또는 비밀번호가 올바르지 않습니다.';
        case 'Email not confirmed':
          return '이메일을 확인해주세요.';
        case 'User already registered':
          return '이미 등록된 이메일입니다.';
        case 'Password should be at least 6 characters':
          return '비밀번호는 최소 6자 이상이어야 합니다.';
        default:
          return error.message;
      }
    }
    return error.toString();
  }
}
