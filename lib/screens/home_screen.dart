import 'package:flutter/material.dart';
import 'package:orange_potion_2/config/supabase_config.dart';
import 'package:provider/provider.dart';
import './product_list_screen.dart';
import './cart_screen.dart';
import './profile_screen.dart';
import '../widgets/search_bar.dart';
import '../providers/products_provider.dart';
import '../providers/user_preference_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const ProductListScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userPrefProvider = Provider.of<UserPreferenceProvider>(context, listen: false);
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      
      await userPrefProvider.loadPreferences();
      await productsProvider.fetchProducts();

      // 로그인 상태이고 취향 데이터가 없으면 취향 테스트로 이동
      if (mounted && 
          supabase.auth.currentUser != null && 
          !userPrefProvider.hasTastePreference) {
        Navigator.of(context).pushNamed('/taste-test');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orange Potion',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: Colors.black),
            onPressed: () async {
              await Navigator.of(context).pushNamed('/taste-test');
              if (mounted) {
                Provider.of<ProductsProvider>(context, listen: false)
                    .fetchProducts();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '장바구니',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}