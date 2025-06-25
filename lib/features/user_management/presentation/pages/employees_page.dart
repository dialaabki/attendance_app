import 'package:attendance_app/core/common_widgets/admin_page_shell.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/user_management/business/usecases/get_all_employees.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});
  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late final Stream<dartz.Either<dynamic, List<UserEntity>>> _employeesStream;

  @override
  void initState() {
    super.initState();
    final getAllEmployeesUseCase = sl<GetAllEmployees>();
    _employeesStream = getAllEmployeesUseCase.watch(NoParams());

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDAC844);

    return AdminPageShell(
      title: 'All Employees',
      selectedNavIndex: 0,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_employee'),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<dartz.Either<dynamic, List<UserEntity>>>(
                stream: _employeesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('No employees found.'));
                  }

                  return snapshot.data!.fold(
                    (failure) => Center(child: Text('Error: ${failure.toString()}')),
                    (employees) {
                      if (employees.isEmpty) {
                        return const Center(child: Text('No employees have been added yet.'));
                      }

                      final filteredList = employees.where((employee) {
                        return employee.fullName.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (filteredList.isEmpty) {
                        return const Center(child: Text('No employees match your search.'));
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final employee = filteredList[index];
                          return _buildEmployeeTile(employee.fullName, employee.uid);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildEmployeeTile(String name, String employeeId) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/timesheet_details',
            arguments: {'id': employeeId, 'name': name},
          );
        },
        leading: const Icon(Icons.person_outline, size: 30, color: Colors.black54),
        title: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}