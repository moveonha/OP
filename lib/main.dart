// lib/main.dart
import 'package:flutter/material.dart';
import 'package:orange_potion_2/screens/login_screen.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/home_screen.dart';
import './screens/profile_screen.dart';
import './screens/taste_test_screen.dart';
import 'package:provider/provider.dart';
import './providers/products_provider.dart';
import './providers/cart_provider.dart';
import './providers/auth_provider.dart';
import './providers/user_preference_provider.dart';
import './providers/recommendation_provider.dart';
import './config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SupabaseConfig.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsProvider()..fetchProducts(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserPreferenceProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RecommendationProvider(),  // 추가
        ),
      ],
      child: MaterialApp(
        title: 'Orange Potion',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          colorScheme: const ColorScheme.light(
            primary: Colors.orange,
            secondary: Colors.orangeAccent,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/product-detail': (_) => const ProductDetailScreen(),
          '/cart': (_) => const CartScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/taste-test': (_) => const TasteTestScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product-detail') {
            final productId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ProductDetailScreen(),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }
}