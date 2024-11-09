// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:orange_potion_2/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '로그인이 필요합니다',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 로그인 화면으로 이동할 때 MaterialPageRoute 사용
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('로그인하기'),
                  ),
                ],
              ),
            );
          }

          // 로그인된 상태의 UI
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요, ${authProvider.user?.email ?? "사용자"}님',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.psychology),
                  title: const Text('취향 테스트 다시하기'),
                  onTap: () {
                    Navigator.pushNamed(context, '/taste-test');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('로그아웃'),
                  onTap: () async {
                    await authProvider.signOut();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}