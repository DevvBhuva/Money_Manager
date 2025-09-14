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
        ChangeNotifierProvider<ExpenseProvider>(create: (_) => ExpenseProvider()),
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

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated && authProvider.currentUser != null) {
          // Initialize other providers when user is authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeProviders(authProvider.currentUser!.id);
          });
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }

  void _initializeProviders(String userId) {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    // Initialize providers with user data
    expenseProvider.initialize(userId);
    groupProvider.initialize(userId);
  }
}
