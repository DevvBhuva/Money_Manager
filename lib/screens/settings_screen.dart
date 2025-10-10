import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../utils/app_constants.dart';
import '../utils/date_utils.dart';
import 'account_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                // Comprehensive User Details Header
                _buildUserDetailsHeader(user),
                const SizedBox(height: AppConstants.paddingLarge),

                // Account Settings
                _buildSectionTitle('Account Settings'),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildSettingsList(context),
                const SizedBox(height: AppConstants.paddingLarge),

                // App Information
                _buildSectionTitle('App Information'),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildAppInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserDetailsHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.radiusLarge)),
        boxShadow: [
          BoxShadow(
            color: AppConstants.shadowColor,
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar and Basic Info
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'User',
                      style: AppConstants.headingMedium.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: AppConstants.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    if (user?.phoneNumber != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user!.phoneNumber!,
                        style: AppConstants.bodySmall.copyWith(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Family Information
          if (user != null) ...[
            _buildUserDetailRow('Role in Family', user.roleInFamily, Icons.family_restroom),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildUserDetailRow('Total Family Income', AppDateUtils.formatCurrency(user.totalFamilyIncome), Icons.account_balance_wallet),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildUserDetailRow('Account Created', AppDateUtils.formatDateForDisplay(user.createdAt), Icons.calendar_today),
            
            // Family Members Section
            if (user.familyMembers.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              const Divider(color: Colors.white30),
              const SizedBox(height: AppConstants.paddingSmall),
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Family Members (${user.familyMembers.length})',
                    style: AppConstants.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              ...user.familyMembers.take(3).map((member) => 
                Padding(
                  padding: const EdgeInsets.only(left: 28, bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '• ${member.name}',
                        style: AppConstants.bodySmall.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      // Text(
                      //   '(${member.relationship})',
                      //   style: AppConstants.bodySmall.copyWith(color: Colors.white60),
                      // ),
                      if (member.monthlyIncome != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '- ${AppDateUtils.formatCurrency(member.monthlyIncome!)}',
                          style: AppConstants.bodySmall.copyWith(color: Colors.white60),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (user.familyMembers.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 28, top: 4),
                  child: Text(
                    '... and ${user.familyMembers.length - 3} more',
                    style: AppConstants.bodySmall.copyWith(color: Colors.white60),
                  ),
                ),
            ],
            
            // Dependencies Section
            if (user.dependencies.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              const Divider(color: Colors.white30),
              const SizedBox(height: AppConstants.paddingSmall),
              Row(
                children: [
                  const Icon(Icons.support, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Dependencies (${user.dependencies.length})',
                    style: AppConstants.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              ...user.dependencies.take(3).map((dep) => 
                Padding(
                  padding: const EdgeInsets.only(left: 28, bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '• ${dep.name}',
                        style: AppConstants.bodySmall.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${dep.type})',
                        style: AppConstants.bodySmall.copyWith(color: Colors.white60),
                      ),
                      if (dep.age != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '- Age: ${dep.age}',
                          style: AppConstants.bodySmall.copyWith(color: Colors.white60),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (user.dependencies.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 28, top: 4),
                  child: Text(
                    '... and ${user.dependencies.length - 3} more',
                    style: AppConstants.bodySmall.copyWith(color: Colors.white60),
                  ),
                ),
            ],
            
            // Budget Preferences
            if (user.budgetPreferences.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              const Divider(color: Colors.white30),
              const SizedBox(height: AppConstants.paddingSmall),
              Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Budget Preferences',
                    style: AppConstants.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: user.budgetPreferences.map((pref) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Text(
                      pref,
                      style: AppConstants.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ),
                ).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppConstants.bodyMedium.copyWith(color: Colors.white70),
        ),
        Expanded(
          child: Text(
            value,
            style: AppConstants.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppConstants.headingSmall.copyWith(color: AppConstants.textPrimary),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: AppConstants.shadowColorLight,
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
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
        padding: const EdgeInsets.all(AppConstants.paddingSmall),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(AppConstants.radiusSmall)),
        ),
        child: Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppConstants.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppConstants.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, color: AppConstants.shadowColorLight);
  }

  Widget _buildAppInfo() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: AppConstants.shadowColorLight,
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
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
      title: Text(
        title,
        style: AppConstants.bodyMedium,
      ),
      trailing: Text(
        value,
        style: AppConstants.bodyMedium.copyWith(
          color: AppConstants.primaryColor,
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
        content: Text(
          message,
          style: AppConstants.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppConstants.radiusSmall)),
        ),
      ),
    );
  }
}
