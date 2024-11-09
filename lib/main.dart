import 'package:flutter/material.dart';
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
          create: (_) => ProductsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserPreferenceProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
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
            '/profile': (_) => const ProfileScreen(),
            '/taste-test': (_) => const TasteTestScreen(),
          },
        ),
      ),
    );
  }
}