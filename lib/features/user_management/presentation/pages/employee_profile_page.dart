import 'package:attendance_app/core/common_widgets/employee_page_shell.dart';
import 'package:attendance_app/core/common_widgets/hr_page_shell.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/auth/business/usecases/get_current_user.dart';
import 'package:attendance_app/features/auth/business/usecases/logout_user.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:flutter/material.dart';

class EmployeeProfilePage extends StatefulWidget {
  // Flag to determine which shell to use
  final bool isHr;

  const EmployeeProfilePage({super.key, this.isHr = false});
  
  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  UserEntity? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final getCurrentUser = sl<GetCurrentUser>();
    final result = await getCurrentUser(NoParams());
    if (mounted) {
      result.fold(
        (failure) => setState(() => _isLoading = false),
        (user) => setState(() {
          _userData = user;
          _isLoading = false;
        }),
      );
    }
  }

  Future<void> _logout() async {
    final logoutUser = sl<LogoutUser>();
    await logoutUser(NoParams());
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // Helper method to build the body content to avoid duplication
  Widget _buildContent() {
    return _isLoading
      ? const Center(child: CircularProgressIndicator())
      : _userData == null
          ? const Center(child: Text('Could not load user profile.'))
          : ListView(
              padding: const EdgeInsets.all(25.0),
              children: [
                _buildInfoTile(icon: Icons.person_outline, label: 'Full Name', value: _userData!.fullName),
                const Divider(),
                _buildInfoTile(icon: Icons.email_outlined, label: 'Email', value: _userData!.email),
                const Divider(),
                _buildInfoTile(icon: Icons.badge_outlined, label: 'Role', value: _userData!.role),
                const Divider(),
                _buildInfoTile(icon: Icons.work_outline, label: 'Employee Type', value: _userData!.type),
                const Divider(),
                _buildInfoTile(icon: Icons.attach_money, label: 'Salary', value: _userData!.salary.toStringAsFixed(2)),
                const SizedBox(height: 50),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(child: Text('App Version 1.0.0', style: TextStyle(color: Colors.grey))),
              ],
            );
  }

  @override
  Widget build(BuildContext context) {
    final String userNameForShell = _userData?.fullName.split(' ')[0] ?? 'User';

    // Conditionally choose the correct page shell
    if (widget.isHr) {
      return HrPageShell(
        selectedNavIndex: 3, // Corresponds to 'Profile' in the HR nav
        userName: userNameForShell,
        child: _buildContent(),
      );
    }

    return EmployeePageShell(
      selectedNavIndex: 2, // Corresponds to 'Profile' in the Employee nav
      userName: userNameForShell,
      child: _buildContent(),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}