// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../config/supabase_config.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data;
          if (userData == null) {
            return const Center(child: Text('로그인이 필요합니다.'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 헤더
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData['name'] ?? '사용자',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userData['email'] ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 사용자 정보 섹션
                  _buildSection('개인정보', [
                    _buildInfoTile('이메일', userData['email']),
                    if (userData['preferences'] != null)
                      _buildPreferencesTile(userData['preferences']),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // 취향 테스트 섹션
                  _buildSection('취향 분석', [
                    _buildActionTile('취향 테스트 하기', Icons.psychology, () {
                      Navigator.pushNamed(context, '/taste-test');
                    }),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // 주문 관리 섹션
                  _buildSection('주문 관리', [
                    _buildActionTile('주문 내역', Icons.shopping_bag, () {}),
                    _buildActionTile('장바구니', Icons.shopping_cart, () {
                      Navigator.pushNamed(context, '/cart');
                    }),
                    _buildActionTile('찜한 상품', Icons.favorite, () {}),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // 설정 섹션
                  _buildSection('설정', [
                    _buildActionTile('개인정보 수정', Icons.edit, () {}),
                    _buildActionTile('로그아웃', Icons.logout, () async {
                      await supabase.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    }),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _loadUserData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, Object? value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value?.toString() ?? '미설정'),
      dense: true,
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      dense: true,
    );
  }

  Widget _buildPreferencesTile(Map<String, dynamic> preferences) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: preferences.entries.map((e) {
          final value = (e.value as num).toDouble();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(e.key),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: value / 5,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${value.toStringAsFixed(1)}/5'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}