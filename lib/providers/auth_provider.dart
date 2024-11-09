// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;
import '../config/supabase_config.dart';

class AuthProvider with ChangeNotifier {
  app_user.User? _user;
  bool _isLoading = false;
  String? _error;

  app_user.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
          .select()
          .eq('id', userId)
          .single();

      _user = app_user.User.fromJson(response);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        });

        await _loadUserData(response.user!.id);
      }
    } catch (e) {
      _error = '회원가입에 실패했습니다: ${e.toString()}';
      _user = null;
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
    Map<String, dynamic>? preferences,
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
        if (preferences != null) 'preferences': preferences,
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