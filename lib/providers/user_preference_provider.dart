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

  Future<void> savePreferences({
    required double sweet,
    required double bitter,
    required double sour,
    required double body,
    required double alcohol,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

      final preferences = {
        'sweet': sweet,
        'bitter': bitter,
        'sour': sour,
        'body': body,
        'alcohol': alcohol,
      };

      final data = {
        'user_id': userId,
        'preferences': preferences,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from('users')
          .update(data)
          .eq('id', userId);

      _preference = UserPreference(
        userId: userId,
        preferences: preferences,
        updatedAt: DateTime.now(),
      );
      
      _error = null;
    } catch (e) {
      _error = e.toString();
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
      if (userId == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      _preference = UserPreference.fromJson(response);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}