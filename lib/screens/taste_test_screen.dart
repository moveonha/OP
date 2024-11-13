import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preference_provider.dart';
import '../providers/products_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  Future<void> _loadExistingPreferences() async {
    final provider = context.read<UserPreferenceProvider>();
    final existingPreferences = provider.preferences;
    if (existingPreferences.isNotEmpty) {
      setState(() {
        _preferences.addAll(Map<String, double>.from(existingPreferences));
      });
    }
  }

  Future<void> _saveTasteTest() async {
    if (!mounted) return;

    try {
      final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 선호도 값을 0-1 범위로 정규화
      final normalizedPreferences = Map<String, double>.from(_preferences)
        ..updateAll((key, value) => value / 5.0);

      await provider.updatePreferences(normalizedPreferences);
      
      // 데이터 즉시 로드
      await provider.loadPreferences();

      if (!mounted) return;

      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('취향 테스트가 완료되었습니다!')),
      );

      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

      if (mounted) {
        Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
      }

    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('취향 테스트 종료'),
            content: const Text('취향 테스트를 종료하시겠습니까?\n입력하신 데이터는 저장되지 않습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('계속하기'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('종료'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('취향 테스트'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
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
                      value: _preferences[_questions[_currentIndex]['key']]!,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: _preferences[_questions[_currentIndex]['key']]!
                          .toString(),
                      onChanged: (value) {
                        setState(() {
                          _preferences[_questions[_currentIndex]['key']!] = value;
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
                        await _saveTasteTest();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
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
      ),
    );
  }
}