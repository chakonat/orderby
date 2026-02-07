import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/orders_screen.dart';
import 'state/app_state.dart';

const appBackground = Color(0xFFF7F2EC);
const appSurface = Color(0xFFFFFBF7);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OrderbyApp());
}

class OrderbyApp extends StatelessWidget {
  const OrderbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E5C4F),
      brightness: Brightness.light,
      surface: appSurface,
    ).copyWith(
      primary: const Color(0xFF1E5C4F),
      onPrimary: Colors.white,
      secondary: const Color(0xFFF2A74B),
      onSecondary: const Color(0xFF3D2B1F),
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: appSurface,
      onSurface: const Color(0xFF1B1B1B),
      primaryContainer: const Color(0xFFD5E8E2),
      onPrimaryContainer: const Color(0xFF0C352E),
      secondaryContainer: const Color(0xFFFFE2C4),
      onSecondaryContainer: const Color(0xFF3D2B1F),
    );

    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Orderby',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colorScheme,
          useMaterial3: true,
          fontFamily: 'NotoSans',
          scaffoldBackgroundColor: appBackground,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Color(0xFF1B1B1B),
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B1B1B),
            ),
          ),
          cardTheme: CardThemeData(
            color: colorScheme.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: colorScheme.surface,
            selectedColor: colorScheme.primaryContainer,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            prefixIconColor: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        home: const RootShell(),
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int currentIndex = 0;

  final screens = const [
    HomeScreen(),
    CartScreen(),
    OrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final state = context.watch<AppState>();

    if (!state.isAuthenticated) {
      return const AuthScreen();
    }

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        backgroundColor: colors.surface,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_rounded), label: 'Басты'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Себет'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Тапсырыс'),
        ],
      ),
    );
  }
}
