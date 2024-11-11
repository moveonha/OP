import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/home_screen.dart';
import './screens/profile_screen.dart';
import './screens/taste_test_screen.dart';
import './screens/login_screen.dart';
import './screens/signup_screen.dart';
import 'package:provider/provider.dart';
import './providers/products_provider.dart';
import './providers/cart_provider.dart';
import './providers/auth_provider.dart';
import './providers/user_preference_provider.dart';
import './providers/recommendation_provider.dart';
import './config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
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
          create: (_) => UserPreferenceProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsProvider()..fetchProducts(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RecommendationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Orange Potion',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.light,
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
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/cart': (context) => const CartScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/taste-test': (context) => const TasteTestScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                productId: args['productId'] as String,
              ),
            );
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}