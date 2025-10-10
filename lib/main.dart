import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/group_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ExpenseProvider>(
          create: (_) => ExpenseProvider(),
        ),
        ChangeNotifierProvider<GroupProvider>(create: (_) => GroupProvider()),
      ],
      child: MaterialApp(
        title: 'Money Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh authentication status when app is resumed
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshAuthStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print(
          'AuthWrapper - isLoading: ${authProvider.isLoading}, isAuthenticated: ${authProvider.isAuthenticated}, user: ${authProvider.currentUser?.name}',
        );

        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated && authProvider.currentUser != null) {
          print('User is authenticated, showing dashboard');
          // Initialize other providers when user is authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeProviders(authProvider.currentUser!.id);
          });
          return const DashboardScreen();
        } else {
          print('User not authenticated, showing login screen');
          return const LoginScreen();
        }
      },
    );
  }

  void _initializeProviders(String userId) {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    // Initialize providers with user data
    expenseProvider.initialize(userId);
    groupProvider.initialize(userId);
  }
}
