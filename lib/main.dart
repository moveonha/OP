import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/home_screen.dart';
import './screens/profile_screen.dart';
import './screens/taste_test_screen.dart';  // 추가
import 'package:provider/provider.dart';
import './providers/products_provider.dart';
import './providers/cart_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://kjmhbsqkaikypiicxoll.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtqbWhic3FrYWlreXBpaWN4b2xsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEwNjE3NzQsImV4cCI6MjA0NjYzNzc3NH0.jiYIisz2ytmfLBF7X9JkXijjbhhtPuTZ0YPyYqW6Wew',
  );
  
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
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
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/product-detail': (_) => const ProductDetailScreen(),
          '/cart': (_) => const CartScreen(),
          '/profile': (_) => ProfileScreen(),
          '/taste-test': (_) => const TasteTestScreen(),  // 추가
        },
      ),
    );
  }
}