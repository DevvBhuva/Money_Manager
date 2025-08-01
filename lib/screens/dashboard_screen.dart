import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'expenses_screen.dart';
import 'groups_screen.dart';
import 'tracker_screen.dart';
import 'account_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Default to Expenses tab
  final GlobalKey<ExpensesScreenState> _expensesKey = GlobalKey<ExpensesScreenState>();
  final GlobalKey<GroupsScreenState> _groupsKey = GlobalKey<GroupsScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ExpensesScreen(key: _expensesKey),
      GroupsScreen(key: _groupsKey),
      const TrackerScreen(),
      const AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Money Manager',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedIndex == 3) // Only show logout in Account tab
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
            ),
        ],
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 3 ? null : FloatingActionButton(
        onPressed: () {
          // Handle FAB press based on selected tab
          if (_selectedIndex == 0) {
            // Expenses tab - add expense
            _expensesKey.currentState?.addExpense();
          } else if (_selectedIndex == 1) {
            // Groups tab - add group
            _groupsKey.currentState?.addGroup();
          }
        },
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF667eea),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
} 