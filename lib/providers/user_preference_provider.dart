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
        'sweet': sweet,           // 단맛
        'sour': sour,            // 신맛
        'bitter': bitter,         // 쓴맛
        'turbidity': turbidity,   // 탁도
        'fragrance': fragrance,   // 향
        'crisp': crisp,          // 청량함
      };

      final data = {
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
      if (userId == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      if (response == null) {
        // 사용자 데이터가 없으면 기본값으로 생성
        _preference = UserPreference.createDefault(userId);
        await savePreferences(
          sweet: 0,
          sour: 0,
          bitter: 0,
          turbidity: 0,
          fragrance: 0,
          crisp: 0,
        );
      } else {
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