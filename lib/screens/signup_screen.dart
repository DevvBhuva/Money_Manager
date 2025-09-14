import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Family details
  String? _selectedRole;
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
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  // ========== STEP VALIDATION METHODS ==========

  bool _validateStep(int step) {
    switch (step) {
      case 0: // Basic Information
        return _validateBasicInfoStep();
      case 1: // Family Details
        return _validateFamilyDetailsStep();
      case 2: // Dependencies
        return _validateDependenciesStep();
      case 3: // Budget Preferences
        return _validateBudgetPreferencesStep();
      default:
        return false;
    }
  }

  bool _validateBasicInfoStep() {
    return _formKey.currentState?.validate() ?? false;
  }

  bool _validateFamilyDetailsStep() {
    if (_selectedRole == null) {
      _showValidationError('Please select your role in family');
      return false;
    }
    return true;
  }

  bool _validateDependenciesStep() {
    // Dependencies are optional, so this step is always valid
    return true;
  }

  bool _validateBudgetPreferencesStep() {
    if (_selectedBudgetPreferences.isEmpty) {
      _showValidationError('Please select at least one budget preference');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _addFamilyMember() {
    setState(() {
      _familyNameControllers.add(TextEditingController());
      _familyIncomeControllers.add(TextEditingController());
      _familyOccupationControllers.add(TextEditingController());
      _familyRelationships.add('');
      _familyMembers.add(FamilyMember(
        name: '',
        relationship: '',
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
      _dependencyTypes.add('');
      _dependencyRelationships.add('');
      _dependencies.add(Dependency(
        name: '',
        type: '',
        relationship: '',
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

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    // Update family members and dependencies
    _updateFamilyMembers();
    _updateDependencies();

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      roleInFamily: _selectedRole ?? 'Individual',
      familyMembers: _familyMembers,
      dependencies: _dependencies,
      totalFamilyIncome: _calculateTotalIncome(),
      budgetPreferences: _selectedBudgetPreferences,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        const SizedBox(height: 16),

        // Password Field
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (!AuthService.isValidPassword(value)) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Confirm Password Field
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
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
            labelText: 'Your Role in Family *',
            prefixIcon: const Icon(Icons.family_restroom),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          hint: const Text('Select your role'),
          items: _familyRoles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your role in family';
            }
            return null;
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
          'Select at least one budget type you want to focus on *',
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
                            'Create Account',
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
                                          if (_validateStep(_currentStep)) {
                                            setState(() {
                                              _currentStep++;
                                            });
                                          }
                                        }
                                      : (_isLoading ? null : _signup),
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
                                              : 'Create Account',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Color(0xFF667eea),
                                    fontWeight: FontWeight.bold,
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