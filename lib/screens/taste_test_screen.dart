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
    'sweet': 0.0,
    'bitter': 0.0,
    'sour': 0.0,
    'body': 0.0,
    'alcohol': 0.0,
  };

  int _currentIndex = 0;

  final List<Map<String, String>> _questions = [
    {'key': 'sweet', 'question': '단맛을 얼마나 선호하시나요?'},
    {'key': 'bitter', 'question': '쓴맛을 얼마나 선호하시나요?'},
    {'key': 'sour', 'question': '신맛을 얼마나 선호하시나요?'},
    {'key': 'body', 'question': '바디감은 어느 정도를 선호하시나요?'},
    {'key': 'alcohol', 'question': '선호하는 도수는 어느 정도인가요?'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentKey = _questions[_currentIndex]['key'] ?? '';
    final currentValue = _preferences[currentKey] ?? 0.0;

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
              _questions[_currentIndex]['question'] ?? '',
              style: Theme.of(context).textTheme.titleLarge, // headline6 대신 titleLarge 사용
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Slider(
              value: currentValue,
              min: 0,
              max: 5,
              divisions: 5,
              label: currentValue.toString(),
              onChanged: (value) {
                setState(() {
                  _preferences[currentKey] = value;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _handleButtonPress(context);
              },
              child: Text(_currentIndex < _questions.length - 1 ? '다음' : '완료'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleButtonPress(BuildContext context) async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      try {
        // 테스트 완료 및 결과 저장
        final provider = context.read<UserPreferenceProvider>();
        await provider.savePreferences(
          sweet: _preferences['sweet']!,
          bitter: _preferences['bitter']!,
          sour: _preferences['sour']!,
          body: _preferences['body']!,
          alcohol: _preferences['alcohol']!,
        );

        if (!mounted) return;

        // 성공적으로 저장된 후 화면 이동
        Navigator.of(context).pop();
        
        // 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('취향 테스트가 완료되었습니다!')),
        );
      } catch (error) {
        if (!mounted) return;
        
        // 에러 발생시 스낵바로 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $error')),
        );
      }
    }
  }
}