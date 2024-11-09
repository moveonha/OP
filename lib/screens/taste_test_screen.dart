// lib/screens/taste_test_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preference_provider.dart';

class TasteTestScreen extends StatefulWidget {
  const TasteTestScreen({Key? key}) : super(key: key);

  @override
  State<TasteTestScreen> createState() => _TasteTestScreenState();
}

class _TasteTestScreenState extends State<TasteTestScreen> {
  final Map<String, double> _preferences = {
    'sweet': 0.0,      // 단맛
    'sour': 0.0,       // 신맛
    'bitter': 0.0,     // 쓴맛
    'turbidity': 0.0,  // 탁도
    'fragrance': 0.0,  // 향
    'crisp': 0.0,      // 청량함
  };

  int _currentIndex = 0;

  final List<Map<String, String>> _questions = [
    {'key': 'sweet', 'question': '단맛을 얼마나 선호하시나요?', 
     'description': '전통주에서 느껴지는 단맛의 정도를 선택해주세요.'},
    {'key': 'sour', 'question': '신맛을 얼마나 선호하시나요?',
     'description': '전통주의 발효과정에서 생성되는 신맛의 정도를 선택해주세요.'},
    {'key': 'bitter', 'question': '쓴맛을 얼마나 선호하시나요?',
     'description': '전통주에서 느껴지는 쓴맛의 정도를 선택해주세요.'},
    {'key': 'turbidity', 'question': '탁도는 어느 정도를 선호하시나요?',
     'description': '맑은 술부터 탁한 술까지, 선호하는 탁도를 선택해주세요.'},
    {'key': 'fragrance', 'question': '향은 어느 정도를 선호하시나요?',
     'description': '전통주에서 느껴지는 향의 강도를 선택해주세요.'},
    {'key': 'crisp', 'question': '청량감은 어느 정도를 선호하시나요?',
     'description': '깔끔하고 상쾌한 맛의 정도를 선택해주세요.'},
  ];

  String get currentKey => _questions[_currentIndex]['key'] ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('취향 테스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _questions[_currentIndex]['question']!,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _questions[_currentIndex]['description']!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('약함'),
                Expanded(
                  child: Slider(
                    value: _preferences[currentKey] ?? 0.0,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _preferences[currentKey]?.toString() ?? '0.0',
                    onChanged: (value) {
                      setState(() {
                        _preferences[currentKey] = value;
                      });
                    },
                  ),
                ),
                const Text('강함'),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex--;
                      });
                    },
                    child: const Text('이전'),
                  )
                else
                  const SizedBox(width: 80),
                ElevatedButton(
                  onPressed: () async {
                    if (_currentIndex < _questions.length - 1) {
                      setState(() {
                        _currentIndex++;
                      });
                    } else {
                      try {
                        final provider = context.read<UserPreferenceProvider>();
                        await provider.savePreferences(
                          sweet: _preferences['sweet']!,
                          sour: _preferences['sour']!,
                          bitter: _preferences['bitter']!,
                          turbidity: _preferences['turbidity']!,
                          fragrance: _preferences['fragrance']!,
                          crisp: _preferences['crisp']!,
                        );

                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('취향 테스트가 완료되었습니다!')),
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('오류가 발생했습니다: $error')),
                        );
                      }
                    }
                  },
                  child: Text(_currentIndex < _questions.length - 1 ? '다음' : '완료'),
                ),
                if (_currentIndex < _questions.length - 1)
                  const SizedBox(width: 80)
                else
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('건너뛰기'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}