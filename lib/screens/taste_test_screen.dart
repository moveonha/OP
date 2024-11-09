// lib/screens/taste_test_screen.dart
import 'package:flutter/material.dart';
import 'package:orange_potion_2/main.dart';

class TasteTestScreen extends StatefulWidget {
  const TasteTestScreen({Key? key}) : super(key: key);

  @override
  State<TasteTestScreen> createState() => _TasteTestScreenState();
}

class _TasteTestScreenState extends State<TasteTestScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, double> _userPreferences = {
    'sweet': 0.0,
    'bitter': 0.0,
    'sour': 0.0,
    'body': 0.0,
    'alcohol': 0.0,
  };

  final List<Map<String, dynamic>> _questions = [
    {
      'question': '단맛을 얼마나 선호하시나요?',
      'preference': 'sweet',
      'description': '0은 전혀 달지 않은 것, 5는 매우 단 것을 의미합니다.',
    },
    {
      'question': '쓴맛을 얼마나 선호하시나요?',
      'preference': 'bitter',
      'description': '0은 전혀 쓰지 않은 것, 5는 매우 쓴 것을 의미합니다.',
    },
    {
      'question': '신맛을 얼마나 선호하시나요?',
      'preference': 'sour',
      'description': '0은 전혀 시지 않은 것, 5는 매우 신 것을 의미합니다.',
    },
    {
      'question': '바디감은 어느 정도를 선호하시나요?',
      'preference': 'body',
      'description': '0은 매우 가벼운 것, 5는 매우 무거운 것을 의미합니다.',
    },
    {
      'question': '선호하는 도수는 어느 정도인가요?',
      'preference': 'alcohol',
      'description': '0은 낮은 도수, 5는 높은 도수를 의미합니다.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주류 취향 테스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _questions[_currentQuestionIndex]['description'],
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Slider(
              value: _userPreferences[_questions[_currentQuestionIndex]['preference']]!,
              min: 0,
              max: 5,
              divisions: 5,
              label: _userPreferences[_questions[_currentQuestionIndex]['preference']]!.toString(),
              onChanged: (value) {
                setState(() {
                  _userPreferences[_questions[_currentQuestionIndex]['preference']] = value;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_currentQuestionIndex < _questions.length - 1) {
                  setState(() {
                    _currentQuestionIndex++;
                  });
                } else {
                  // 테스트 완료 및 결과 저장
                  _saveTestResults();
                }
              },
              child: Text(
                _currentQuestionIndex < _questions.length - 1 ? '다음' : '완료',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTestResults() async {
    // Supabase에 결과 저장
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase.from('user_preferences').upsert({
        'user_id': userId,
        'preferences': _userPreferences,
      });
    }
    
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('취향 테스트가 완료되었습니다!')),
      );
    }
  }
}