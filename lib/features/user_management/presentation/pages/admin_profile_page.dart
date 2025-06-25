import 'package:attendance_app/core/common_widgets/admin_page_shell.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/auth/business/usecases/get_current_user.dart';
import 'package:attendance_app/features/auth/business/usecases/logout_user.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:flutter/material.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});
  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
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

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'My Profile',
      selectedNavIndex: 3,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('Could not load user profile.'))
              : ListView(
                  padding: const EdgeInsets.all(25.0),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.shield_outlined, size: 50, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        _userData!.fullName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    _buildInfoTile(icon: Icons.email_outlined, label: 'Email', value: _userData!.email),
                    const Divider(),
                    _buildInfoTile(icon: Icons.badge_outlined, label: 'Role', value: _userData!.role),
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
                  ],
                ),
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