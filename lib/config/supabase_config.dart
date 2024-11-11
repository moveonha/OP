// lib/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase 클라이언트 인스턴스
final supabase = Supabase.instance.client;

// Supabase 프로젝트 URL과 anon key
class SupabaseConfig {
  static const String supabaseUrl = 'https://hrgrgwwkipomuxclipie.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhyZ3Jnd3draXBvbXV4Y2xpcGllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzMDQ3NjIsImV4cCI6MjA0Njg4MDc2Mn0.wBPiLaeXf4aa8p5dtSJ5yvbHnTHB-AkVegYXdShg2KQ';

  // Supabase 초기화 메서드
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true,
    );
  }
}

// 데이터베이스 테이블 이름 상수
class SupabaseTables {
  static const String users = 'users';
  static const String products = 'products';
  static const String userPreferences = 'user_preferences';
  static const String cart = 'cart';
}

// 스토리지 버킷 이름 상수
class SupabaseBuckets {
  static const String productImages = 'product-images';
  static const String userAvatars = 'user-avatars';
}

// 에러 메시지
class SupabaseErrors {
  static const String authError = '인증 오류가 발생했습니다.';
  static const String networkError = '네트워크 오류가 발생했습니다.';
  static const String unknownError = '알 수 없는 오류가 발생했습니다.';
}