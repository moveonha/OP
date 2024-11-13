import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preference_provider.dart';
import '../providers/products_provider.dart';

class TasteTestScreen extends StatefulWidget {
  const TasteTestScreen({Key? key}) : super(key: key);

  @override
  State<TasteTestScreen> createState() => _TasteTestScreenState();
}

class _TasteTestScreenState extends State<TasteTestScreen> with SingleTickerProviderStateMixin {
  final Map<String, double> _preferences = {
    'sweet': 0.0,      // 단맛
    'sour': 0.0,       // 신맛
    'bitter': 0.0,     // 쓴맛
    'turbidity': 0.0,  // 탁도
    'fragrance': 0.0,  // 향
    'crisp': 0.0,      // 청량함
  };

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  final List<Map<String, String>> _questions = [
    {'key': 'sweet', 'question': '단맛을 얼마나 선호하시나요?', 
     'description': '전통주에서 느껴지는 단맛의 정도를 선택해주세요.',
     'icon': '🍯'},
    {'key': 'sour', 'question': '신맛을 얼마나 선호하시나요?',
     'description': '전통주의 발효과정에서 생성되는 신맛의 정도를 선택해주세요.',
     'icon': '🍋'},
    {'key': 'bitter', 'question': '쓴맛을 얼마나 선호하시나요?',
     'description': '전통주에서 느껴지는 쓴맛의 정도를 선택해주세요.',
     'icon': '☕'},
    {'key': 'turbidity', 'question': '탁도는 어느 정도를 선호하시나요?',
     'description': '맑은 술부터 탁한 술까지, 선호하는 탁도를 선택해주세요.',
     'icon': '🥛'},
    {'key': 'fragrance', 'question': '향은 어느 정도를 선호하시나요?',
     'description': '전통주에서 느껴지는 향의 강도를 선택해주세요.',
     'icon': '🌸'},
    {'key': 'crisp', 'question': '청량감은 어느 정도를 선호하시나요?',
     'description': '깔끔하고 상쾌한 맛의 정도를 선택해주세요.',
     'icon': '❄️'},
  ];

    @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _loadExistingPreferences();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _controller.reverse().then((_) {
        setState(() {
          _currentIndex++;
        });
        _controller.forward();
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      _controller.reverse().then((_) {
        setState(() {
          _currentIndex--;
        });
        _controller.forward();
      });
    }
  }

  Future<void> _saveTasteTest() async {
    if (!mounted) return;

    try {
      final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
      
      // 분석 중 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '취향 분석 중...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '당신의 취향을 분석하고 있습니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 선호도 값을 0-1 범위로 정규화
      final normalizedPreferences = Map<String, double>.from(_preferences)
        ..updateAll((key, value) => value / 5.0);

      await provider.updatePreferences(normalizedPreferences);
      await provider.loadPreferences();
      
      // 일부러 딜레이를 주어 분석 중인 것처럼 표시
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 분석 중 다이얼로그 닫기
      Navigator.of(context).pop();

      // 완료 다이얼로그 표시
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade400,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '취향 분석이 완료되었습니다!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '이제 당신의 취향에 맞는 전통주를 추천해드립니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (mounted) {
        Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
      }

    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $error'),
          backgroundColor: Colors.red,
        ),
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
            title: const Text(
              '취향 테스트 종료',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('취향 테스트를 종료하시겠습니까?\n입력하신 데이터는 저장되지 않습니다.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('계속하기'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  '종료',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '취향 테스트',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.orange.shade50],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // 진행 상태 표시
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                    minHeight: 4,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentIndex + 1}/${_questions.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _questions[_currentIndex]['icon']!,
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _questions[_currentIndex]['question']!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _questions[_currentIndex]['description']!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '약함',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '강함',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: Colors.orange,
                                    inactiveTrackColor: Colors.orange.withOpacity(0.2),
                                    thumbColor: Colors.white,
                                    overlayColor: Colors.orange.withOpacity(0.1),
                                    valueIndicatorColor: Colors.orange,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 12,
                                      pressedElevation: 8,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 24,
                                    ),
                                    valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                    valueIndicatorTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  child: Slider(
                                    value: _preferences[_questions[_currentIndex]['key']]!,
                                    min: 0,
                                    max: 5,
                                    divisions: 5,
                                    label: _preferences[_questions[_currentIndex]['key']]!
                                        .toStringAsFixed(1),
                                    onChanged: (value) {
                                      setState(() {
                                        _preferences[_questions[_currentIndex]['key']!] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 네비게이션 버튼
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentIndex > 0)
                          TextButton.icon(
                            onPressed: _previousQuestion,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('이전'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                            ),
                          )
                        else
                          const SizedBox(width: 100),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentIndex < _questions.length - 1) {
                              _nextQuestion();
                            } else {
                              _saveTasteTest();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _currentIndex < _questions.length - 1 ? '다음' : '완료',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_currentIndex < _questions.length - 1)
                          const SizedBox(width: 100)
                        else
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                            ),
                            child: const Text('건너뛰기'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}