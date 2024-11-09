// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;
import '../config/supabase_config.dart';

class AuthProvider with ChangeNotifier {
  app_user.User? _user;
  bool _isLoading = false;
  String? _error;
  bool _needsTasteTest = false;

  app_user.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get needsTasteTest => _needsTasteTest;

  bool get isAuthenticated => _user != null;

  Future<void> initializeUser() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      await _loadUserData(currentUser.id);
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('users')
          .select('*, preferences')
          .eq('id', userId)
          .single();

      _user = app_user.User.fromJson(response);
      
      // 취향 테스트 필요 여부 확인
      final preferences = response['preferences'];
      _needsTasteTest = preferences == null || 
                       (preferences as Map).isEmpty ||
                       !_hasValidPreferences(preferences);
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _hasValidPreferences(Map<dynamic, dynamic> preferences) {
    final requiredFields = [
      'sweet', 'sour', 'bitter', 'turbidity', 'fragrance', 'crisp'
    ];
    return requiredFields.every((field) => 
      preferences.containsKey(field) && 
      preferences[field] != null && 
      preferences[field] is num
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserData(response.user!.id);
      }
    } catch (e) {
      _error = '로그인에 실패했습니다: ${e.toString()}';
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, {String? name}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await supabase.from('users').upsert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'preferences': null, // 초기 취향 데이터는 null로 설정
        });

        await _loadUserData(response.user!.id);
        _needsTasteTest = true; // 새 사용자는 취향 테스트 필요
      }
    } catch (e) {
      _error = '회원가입에 실패했습니다: ${e.toString()}';
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePreferences(Map<String, double> preferences) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _user?.id;
      if (userId == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

      await supabase
          .from('users')
          .update({
            'preferences': preferences,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      await _loadUserData(userId);
      _needsTasteTest = false; // 취향 테스트 완료
    } catch (e) {
      _error = '취향 데이터 업데이트에 실패했습니다: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      _user = null;
      _error = null;
      _needsTasteTest = false;
    } catch (e) {
      _error = '로그아웃에 실패했습니다: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    String? name,
    int? age,
    String? gender,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _user?.id;
      if (userId == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

      final updates = {
        'updated_at': DateTime.now().toIso8601String(),
        if (name != null) 'name': name,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
      };

      await supabase
          .from('users')
          .update(updates)
          .eq('id', userId);

      await _loadUserData(userId);
    } catch (e) {
      _error = '프로필 업데이트에 실패했습니다: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      _error = '비밀번호 재설정 이메일 전송에 실패했습니다: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}