import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userData;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  Map<String, dynamic>? get userData => _userData;

  final _supabase = Supabase.instance.client;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // 현재 세션 확인
      final Session? session = _supabase.auth.currentSession;
      _user = session?.user;
      
      if (_user != null) {
        await _fetchUserData();
      }

      // 인증 상태 변경 리스너
      _supabase.auth.onAuthStateChange.listen((data) async {
        _user = data.session?.user;
        if (_user != null) {
          await _fetchUserData();
        } else {
          _userData = null;
        }
        notifyListeners();
      });
    } catch (e) {
      _error = '초기화 실패: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', _user!.id)
          .single();
      _userData = response;
    } catch (e) {
      print('사용자 데이터 조회 실패: $e');
    }
  }

  Future<void> signUp(String email, String password) async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _error = null;

      // 1. Supabase Auth로 사용자 계정 생성
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'preferences': {
            'sweet': 0.0,
            'sour': 0.0,
            'bitter': 0.0,
            'turbidity': 0.0,
            'fragrance': 0.0,
            'crisp': 0.0,
          },
        },
      );

      if (response.user == null) {
        throw '회원가입 실패: 사용자 생성에 실패했습니다.';
      }

      _user = response.user;

      // 2. users 테이블에 추가 정보가 자동으로 생성됨 (트리거에 의해)
      await _fetchUserData();

    } on AuthException catch (e) {
      _error = e.message;
      _user = null;
      _userData = null;
      if (e.message.contains('already registered')) {
        throw '이미 등록된 이메일입니다.';
      }
      throw '회원가입 실패: ${e.message}';
    } on PostgrestException catch (e) {
      _error = '데이터베이스 오류: ${e.message}';
      _user = null;
      _userData = null;
      throw '회원가입 실패: 데이터베이스 오류가 발생했습니다.';
    } catch (e) {
      _error = '예상치 못한 오류: ${e.toString()}';
      _user = null;
      _userData = null;
      throw '회원가입 실패: 알 수 없는 오류가 발생했습니다.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _error = null;

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _user = response.user;
      if (_user != null) {
        await _fetchUserData();
      }
      
    } on AuthException catch (e) {
      _error = e.message;
      _user = null;
      _userData = null;
      if (e.message.contains('Invalid login credentials')) {
        throw '이메일 또는 비밀번호가 올바르지 않습니다.';
      }
      throw '로그인 실패: ${e.message}';
    } catch (e) {
      _error = '예상치 못한 오류: ${e.toString()}';
      _user = null;
      _userData = null;
      throw '로그인 실패: 알 수 없는 오류가 발생했습니다.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      await _supabase.auth.signOut();
      _user = null;
      _userData = null;
      _error = null;
    } catch (e) {
      _error = '로그아웃 실패: ${e.toString()}';
      throw '로그아웃 실패: 알 수 없는 오류가 발생했습니다.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile({
    String? name,
    int? age,
    String? gender,
    Map<String, dynamic>? preferences,
  }) async {
    if (_isLoading || _user == null) return;

    try {
      _setLoading(true);
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (age != null) updates['age'] = age;
      if (gender != null) updates['gender'] = gender;
      if (preferences != null) updates['preferences'] = preferences;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', _user!.id);
      
      await _fetchUserData();
    } catch (e) {
      _error = '프로필 업데이트 실패: ${e.toString()}';
      throw '프로필 업데이트 실패: 알 수 없는 오류가 발생했습니다.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}