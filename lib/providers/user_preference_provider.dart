import 'package:flutter/foundation.dart';
import '../models/user_preference.dart';
import '../config/supabase_config.dart';

class UserPreferenceProvider with ChangeNotifier {
  UserPreference? _preference;
  bool _isLoading = false;
  String? _error;

  UserPreference? get preference => _preference;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTastePreference => _preference?.preferences.isNotEmpty ?? false;

  Future<void> savePreferences({
    required double sweet,
    required double sour,
    required double bitter,
    required double turbidity,
    required double fragrance,
    required double crisp,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

      final preferences = {
        'sweet': sweet,
        'sour': sour,
        'bitter': bitter,
        'turbidity': turbidity,
        'fragrance': fragrance,
        'crisp': crisp,
      };

      // Supabase에 데이터 저장
      await supabase
          .from('users')
          .update({
            'preferences': preferences,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // 로컬 상태 업데이트
      _preference = UserPreference(
        userId: userId,
        preferences: preferences,
        updatedAt: DateTime.now(),
      );
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error saving preferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPreferences() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        _preference = null;
        return;
      }

      final response = await supabase
          .from('users')
          .select('*, preferences')
          .eq('id', userId)
          .single();

      if (response != null) {
        _preference = UserPreference.fromJson(response);
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading preferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPreferences() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

      await savePreferences(
        sweet: 0,
        sour: 0,
        bitter: 0,
        turbidity: 0,
        fragrance: 0,
        crisp: 0,
      );
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error resetting preferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}