import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                if (user?.phoneNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    user!.phoneNumber!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Settings
          _buildSectionTitle('Account Settings'),
          const SizedBox(height: 16),
          _buildSettingsList(context),
          const SizedBox(height: 24),

          // App Information
          _buildSectionTitle('App Information'),
          const SizedBox(height: 16),
          _buildAppInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            'Edit Profile',
            Icons.person,
            () => _navigateToEditProfile(context),
          ),
          _buildDivider(),
          _buildSettingsItem(
            'Change Password',
            Icons.lock,
            () => _showSnackBar(context, 'Change Password tapped'),
          ),
          _buildDivider(),
          _buildSettingsItem(
            'Notification Settings',
            Icons.notifications,
            () => _showSnackBar(context, 'Notification Settings tapped'),
          ),
          _buildDivider(),
          _buildSettingsItem(
            'Privacy Settings',
            Icons.privacy_tip,
            () => _showSnackBar(context, 'Privacy Settings tapped'),
          ),
          _buildDivider(),
          _buildSettingsItem(
            'Export Data',
            Icons.download,
            () => _showSnackBar(context, 'Export Data tapped'),
          ),
          _buildDivider(),
          _buildSettingsItem(
            'Help & Support',
            Icons.help,
            () => _showSnackBar(context, 'Help & Support tapped'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF667eea).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF667eea),
          size: 20,
        ),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56);
  }

  Widget _buildAppInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoItem('App Version', '1.0.0'),
          _buildDivider(),
          _buildInfoItem('Build Number', '1'),
          _buildDivider(),
          _buildInfoItem('Last Updated', 'December 2024'),
          _buildDivider(),
          _buildInfoItem('Terms of Service', 'View'),
          _buildDivider(),
          _buildInfoItem('Privacy Policy', 'View'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF667eea),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF667eea),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  // Family details
  late String _selectedRole;
  final List<FamilyMember> _familyMembers = [];
  final List<Dependency> _dependencies = [];
  final List<String> _selectedBudgetPreferences = [];
  
  // Form controllers for family members
  final List<TextEditingController> _familyNameControllers = [];
  final List<TextEditingController> _familyIncomeControllers = [];
  final List<TextEditingController> _familyOccupationControllers = [];
  final List<String> _familyRelationships = [];
  
  // Form controllers for dependencies
  final List<TextEditingController> _dependencyNameControllers = [];
  final List<TextEditingController> _dependencyAgeControllers = [];
  final List<TextEditingController> _dependencySpecialNeedsControllers = [];
  final List<String> _dependencyTypes = [];
  final List<String> _dependencyRelationships = [];
  
  bool _isLoading = false;
  int _currentStep = 0;
  
  final List<String> _familyRoles = [
    'Individual',
    'Son',
    'Daughter',
    'Husband',
    'Wife',
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Grandfather',
    'Grandmother',
    'Other'
  ];
  
  final List<String> _availableFamilyRelationships = [
    'Son',
    'Daughter',
    'Husband',
    'Wife',
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Grandfather',
    'Grandmother',
    'Uncle',
    'Aunt',
    'Cousin',
    'Other'
  ];
  
  final List<String> _availableDependencyTypes = [
    'Housewife',
    'Elder Parent',
    'Child',
    'Disabled Family Member',
    'Student',
    'Unemployed',
    'Other'
  ];
  
  final List<String> _budgetOptions = [
    'Daily Budget',
    'Monthly Budget',
    'Quarterly Budget',
    'Individual Budget'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _selectedRole = 'Individual';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      // Update existing controllers
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _selectedRole = user.roleInFamily;
      
      // Clear existing data
      _familyMembers.clear();
      _dependencies.clear();
      _selectedBudgetPreferences.clear();
      
      // Dispose existing controllers
      for (var controller in _familyNameControllers) {
        controller.dispose();
      }
      for (var controller in _familyIncomeControllers) {
        controller.dispose();
      }
      for (var controller in _familyOccupationControllers) {
        controller.dispose();
      }
      for (var controller in _dependencyNameControllers) {
        controller.dispose();
      }
      for (var controller in _dependencyAgeControllers) {
        controller.dispose();
      }
      for (var controller in _dependencySpecialNeedsControllers) {
        controller.dispose();
      }
      
      _familyNameControllers.clear();
      _familyIncomeControllers.clear();
      _familyOccupationControllers.clear();
      _familyRelationships.clear();
      _dependencyNameControllers.clear();
      _dependencyAgeControllers.clear();
      _dependencySpecialNeedsControllers.clear();
      _dependencyTypes.clear();
      _dependencyRelationships.clear();
      
      // Add user data
      _familyMembers.addAll(user.familyMembers);
      _dependencies.addAll(user.dependencies);
      _selectedBudgetPreferences.addAll(user.budgetPreferences);
      
      // Initialize controllers for existing family members
      for (var member in user.familyMembers) {
        _familyNameControllers.add(TextEditingController(text: member.name));
        _familyIncomeControllers.add(TextEditingController(text: member.monthlyIncome?.toString() ?? ''));
        _familyOccupationControllers.add(TextEditingController(text: member.occupation ?? ''));
        _familyRelationships.add(member.relationship);
      }
      
      // Initialize controllers for existing dependencies
      for (var dependency in user.dependencies) {
        _dependencyNameControllers.add(TextEditingController(text: dependency.name));
        _dependencyAgeControllers.add(TextEditingController(text: dependency.age?.toString() ?? ''));
        _dependencySpecialNeedsControllers.add(TextEditingController(text: dependency.specialNeeds ?? ''));
        _dependencyTypes.add(dependency.type);
        _dependencyRelationships.add(dependency.relationship ?? '');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    
    // Dispose family member controllers
    for (var controller in _familyNameControllers) {
      controller.dispose();
    }
    for (var controller in _familyIncomeControllers) {
      controller.dispose();
    }
    for (var controller in _familyOccupationControllers) {
      controller.dispose();
    }
    
    // Dispose dependency controllers
    for (var controller in _dependencyNameControllers) {
      controller.dispose();
    }
    for (var controller in _dependencyAgeControllers) {
      controller.dispose();
    }
    for (var controller in _dependencySpecialNeedsControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  void _addFamilyMember() {
    setState(() {
      _familyNameControllers.add(TextEditingController());
      _familyIncomeControllers.add(TextEditingController());
      _familyOccupationControllers.add(TextEditingController());
      _familyRelationships.add('Son');
      _familyMembers.add(FamilyMember(
        name: '',
        relationship: 'Son',
        monthlyIncome: 0,
        occupation: '',
      ));
    });
  }

  void _removeFamilyMember(int index) {
    setState(() {
      _familyNameControllers[index].dispose();
      _familyIncomeControllers[index].dispose();
      _familyOccupationControllers[index].dispose();
      _familyNameControllers.removeAt(index);
      _familyIncomeControllers.removeAt(index);
      _familyOccupationControllers.removeAt(index);
      _familyRelationships.removeAt(index);
      _familyMembers.removeAt(index);
    });
  }

  void _addDependency() {
    setState(() {
      _dependencyNameControllers.add(TextEditingController());
      _dependencyAgeControllers.add(TextEditingController());
      _dependencySpecialNeedsControllers.add(TextEditingController());
      _dependencyTypes.add('Housewife');
      _dependencyRelationships.add('Spouse');
      _dependencies.add(Dependency(
        name: '',
        type: 'Housewife',
        relationship: 'Spouse',
        age: 0,
        specialNeeds: '',
      ));
    });
  }

  void _removeDependency(int index) {
    setState(() {
      _dependencyNameControllers[index].dispose();
      _dependencyAgeControllers[index].dispose();
      _dependencySpecialNeedsControllers[index].dispose();
      _dependencyNameControllers.removeAt(index);
      _dependencyAgeControllers.removeAt(index);
      _dependencySpecialNeedsControllers.removeAt(index);
      _dependencyTypes.removeAt(index);
      _dependencyRelationships.removeAt(index);
      _dependencies.removeAt(index);
    });
  }

  double _calculateTotalIncome() {
    double total = 0;
    for (int i = 0; i < _familyIncomeControllers.length; i++) {
      final income = double.tryParse(_familyIncomeControllers[i].text) ?? 0;
      total += income;
    }
    return total;
  }

  void _updateFamilyMembers() {
    _familyMembers.clear();
    for (int i = 0; i < _familyNameControllers.length; i++) {
      _familyMembers.add(FamilyMember(
        name: _familyNameControllers[i].text,
        relationship: _familyRelationships[i],
        monthlyIncome: double.tryParse(_familyIncomeControllers[i].text),
        occupation: _familyOccupationControllers[i].text,
      ));
    }
  }

  void _updateDependencies() {
    _dependencies.clear();
    for (int i = 0; i < _dependencyNameControllers.length; i++) {
      _dependencies.add(Dependency(
        name: _dependencyNameControllers[i].text,
        type: _dependencyTypes[i],
        relationship: _dependencyRelationships[i],
        age: int.tryParse(_dependencyAgeControllers[i].text),
        specialNeeds: _dependencySpecialNeedsControllers[i].text,
      ));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Update family members and dependencies
    _updateFamilyMembers();
    _updateDependencies();

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement profile update functionality
    // For now, just show a success message
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 32),
        
        // Name Field
        TextFormField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            if (!AuthService.isValidName(value)) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Email Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!AuthService.isValidEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Phone Field (Optional)
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number (Optional)',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyDetailsStep() {
    return Column(
      children: [
        const Text(
          'Family Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 32),
        
        // Role in Family
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: InputDecoration(
            labelText: 'Your Role in Family',
            prefixIcon: const Icon(Icons.family_restroom),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: _familyRoles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value!;
            });
          },
        ),
        const SizedBox(height: 24),
        
        // Family Members Section
        const Text(
          'Family Members (Earning Members)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        
        // Add Family Member Button
        ElevatedButton.icon(
          onPressed: _addFamilyMember,
          icon: const Icon(Icons.add),
          label: const Text('Add Family Member'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Family Members List
        ...List.generate(_familyMembers.length, (index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Family Member ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _removeFamilyMember(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  TextFormField(
                    controller: _familyNameControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Relationship
                  DropdownButtonFormField<String>(
                    value: _familyRelationships[index],
                    decoration: InputDecoration(
                      labelText: 'Relationship',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _availableFamilyRelationships.map((rel) {
                      return DropdownMenuItem(
                        value: rel,
                        child: Text(rel),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _familyRelationships[index] = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Monthly Income
                  TextFormField(
                    controller: _familyIncomeControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Monthly Income (₹)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Trigger rebuild to update total income display
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Occupation
                  TextFormField(
                    controller: _familyOccupationControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Occupation',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        
        // Total Income Display
        if (_familyMembers.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFF667eea),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Total Family Income: ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${_calculateTotalIncome().toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDependenciesStep() {
    return Column(
      children: [
        const Text(
          'Dependencies',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Add family members who depend on you financially',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        
        // Add Dependency Button
        ElevatedButton.icon(
          onPressed: _addDependency,
          icon: const Icon(Icons.add),
          label: const Text('Add Dependency'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Dependencies List
        ...List.generate(_dependencies.length, (index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Dependency ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _removeDependency(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  TextFormField(
                    controller: _dependencyNameControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Type
                  DropdownButtonFormField<String>(
                    value: _dependencyTypes[index],
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _availableDependencyTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _dependencyTypes[index] = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Relationship
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Relationship',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _dependencyRelationships[index] = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Age
                  TextFormField(
                    controller: _dependencyAgeControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Special Needs
                  TextFormField(
                    controller: _dependencySpecialNeedsControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Special Needs (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBudgetPreferencesStep() {
    return Column(
      children: [
        const Text(
          'Budget Preferences',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Select the types of budgets you want to focus on',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        
        // Budget Options
        ..._budgetOptions.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: _selectedBudgetPreferences.contains(option),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedBudgetPreferences.add(option);
                } else {
                  _selectedBudgetPreferences.remove(option);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }),
        
        const SizedBox(height: 24),
        
        if (_selectedBudgetPreferences.isNotEmpty) ...[
          const Text(
            'Selected Budget Types:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _selectedBudgetPreferences.map((pref) {
              return Chip(
                label: Text(pref),
                backgroundColor: const Color(0xFF667eea),
                labelStyle: const TextStyle(color: Colors.white),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  List<Widget> get _steps => [
    _buildBasicInfoStep(),
    _buildFamilyDetailsStep(),
    _buildDependenciesStep(),
    _buildBudgetPreferencesStep(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _currentStep > 0
                          ? () {
                              setState(() {
                                _currentStep--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (_currentStep + 1) / _steps.length,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Step ${_currentStep + 1} of ${_steps.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: _steps[_currentStep],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Navigation buttons
                          Row(
                            children: [
                              if (_currentStep > 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentStep--;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Previous'),
                                  ),
                                ),
                              if (_currentStep > 0) const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _currentStep < _steps.length - 1
                                      ? () {
                                          if (_formKey.currentState!.validate()) {
                                            setState(() {
                                              _currentStep++;
                                            });
                                          }
                                        }
                                      : (_isLoading ? null : _saveProfile),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF667eea),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                          ),
                                        )
                                      : Text(
                                          _currentStep < _steps.length - 1
                                              ? 'Next'
                                              : 'Save Profile',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 