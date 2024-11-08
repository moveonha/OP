// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  final User user = User(
    id: '1',
    name: '사용자',
    email: 'user@example.com',
    phoneNumber: '010-1234-5678',
    address: '서울시 강남구',
  );

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: SingleChildScrollView(
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
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // 사용자 정보 섹션
              _buildSection('개인정보', [
                _buildInfoTile('이메일', user.email),
                _buildInfoTile('전화번호', user.phoneNumber),
                _buildInfoTile('배송지', user.address),
              ]),
              
              const SizedBox(height: 16),
              
              // 주문 관련 섹션
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
                _buildActionTile('알림 설정', Icons.notifications, () {}),
                _buildActionTile('개인정보 수정', Icons.edit, () {}),
                _buildActionTile('로그아웃', Icons.logout, () {}),
              ]),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
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
}