import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_preference.dart';

class UserPreferenceProvider with ChangeNotifier {
  UserPreference? _userPreference;
  bool _isLoading = false;
  String? _error;

  UserPreference? get userPreference => _userPreference;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, double> get preferences => _userPreference?.preferences ?? {};
  String? get nickname => _userPreference?.nickname;

  bool get hasTastePreference {
    if (_userPreference == null) return false;
    final prefs = _userPreference!.preferences;
    return prefs.isNotEmpty && prefs.values.any((value) => value > 0);
  }

  final _supabase = Supabase.instance.client;

  Future<void> loadPreferences() async {
    if (_isLoading) return;

    final user = _supabase.auth.currentUser;
    if (user == null) {
      _userPreference = null;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      _userPreference = UserPreference.fromJson(response);
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Failed to load preferences: $_error');
      _userPreference = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePreferences(Map<String, double> newPreferences) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다');

    try {
      _isLoading = true;
      notifyListeners();

      await _supabase
          .from('users')
          .update({
            'preferences': newPreferences,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      if (_userPreference != null) {
        _userPreference = _userPreference!.copyWith(
          preferences: newPreferences,
          updatedAt: DateTime.now(),
        );
      } else {
        _userPreference = UserPreference(
          userId: user.id,
          preferences: newPreferences,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      _error = null;
      notifyListeners();
      
      await loadPreferences();
      
    } catch (e) {
      _error = e.toString();
      print('Failed to update preferences: $_error');
      throw Exception('취향 데이터 저장에 실패했습니다');
    }
  }

  Future<void> updateNickname(String newNickname) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다');

    try {
      _isLoading = true;
      notifyListeners();

      await _supabase
          .from('users')
          .update({
            'nickname': newNickname,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      if (_userPreference != null) {
        _userPreference = _userPreference!.copyWith(
          nickname: newNickname,
          updatedAt: DateTime.now(),
        );
      }

      _error = null;
      notifyListeners();
      
      await loadPreferences();
      
    } catch (e) {
      _error = e.toString();
      print('Failed to update nickname: $_error');
      throw Exception('닉네임 설정에 실패했습니다');
    }
  }

  Future<void> resetPreferences() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다');

    try {
      _isLoading = true;
      notifyListeners();

      final defaultPreferences = {
        'sweet': 0.0,
        'sour': 0.0,
        'bitter': 0.0,
        'turbidity': 0.0,
        'fragrance': 0.0,
        'crisp': 0.0,
      };

      await _supabase
          .from('users')
          .update({
            'preferences': defaultPreferences,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      if (_userPreference != null) {
        _userPreference = _userPreference!.copyWith(
          preferences: defaultPreferences,
          updatedAt: DateTime.now(),
        );
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Failed to reset preferences: $_error');
      throw Exception('취향 데이터 초기화에 실패했습니다');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPreferences() {
    _userPreference = null;
    _error = null;
    notifyListeners();
  }
}