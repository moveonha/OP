import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_preference_provider.dart';
import '../widgets/hexagon_stats_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _showNicknameDialog(BuildContext context, UserPreferenceProvider provider) {
    final controller = TextEditingController(text: provider.nickname);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('닉네임 설정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '닉네임',
            hintText: '닉네임을 입력해주세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            filled: true,
            fillColor: Color(0xFFEFEFEF),
          ),
          maxLength: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.updateNickname(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text('내정보'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<AuthProvider, UserPreferenceProvider>(
        builder: (context, authProvider, userPrefProvider, _) {
          if (!authProvider.isAuthenticated) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_circle_outlined,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '로그인이 필요한 서비스입니다',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '로그인하고 취향에 맞는 전통주를 추천받아보세요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '로그인하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 카드
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.orange.shade50,
                          child: const Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    userPrefProvider.nickname ?? 
                                    authProvider.user?.email?.split('@')[0] ?? 
                                    "사용자",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () => _showNicknameDialog(
                                      context,
                                      userPrefProvider,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                authProvider.user?.email ?? "",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 취향 분석 카드
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: userPrefProvider.preferences.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '나의 취향 분석',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/taste-test');
                                    },
                                    child: const Text('다시하기'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: HexagonStatsWidget(
                                  characteristics: userPrefProvider.preferences,
                                  size: MediaQuery.of(context).size.width * 0.7,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListTile(
                          onTap: () {
                            Navigator.pushNamed(context, '/taste-test');
                          },
                          leading: const Icon(
                            Icons.psychology,
                            color: Colors.orange,
                          ),
                          title: const Text('취향 테스트 하러가기'),
                          subtitle: const Text('나만의 취향을 발견해보세요'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // 설정 카드
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('로그아웃'),
                          content: const Text('정말 로그아웃 하시겠습니까?'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                '취소',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await authProvider.signOut();
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text(
                                '로그아웃',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.orange,
                    ),
                    title: const Text('로그아웃'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}