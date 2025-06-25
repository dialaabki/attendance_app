import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_filtered_employees.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:dartz/dartz.dart' as dartz; 
import 'package:flutter/material.dart';

class FilteredEmployeeListPage extends StatefulWidget {
  final EmployeeFilter filter;
  final DateTime date;

  const FilteredEmployeeListPage({super.key, required this.filter, required this.date});
  @override
  _FilteredEmployeeListPageState createState() => _FilteredEmployeeListPageState();
}

class _FilteredEmployeeListPageState extends State<FilteredEmployeeListPage> { 
  late Future<dartz.Either<dynamic, List<UserEntity>>> _filteredUsersFuture; 

  @override
  void initState() {
    super.initState();
    final getFilteredEmployees = sl<GetFilteredEmployees>();
    final params = EmployeeFilterParams(filter: widget.filter, date: widget.date);
    _filteredUsersFuture = getFilteredEmployees(params);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDAC844);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<dartz.Either<dynamic, List<UserEntity>>>( 
        future: _filteredUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Could not load data."));
          }
          
          return snapshot.data!.fold(
            (failure) => Center(child: Text('Error: ${failure.toString()}')), 
            (users) {
              if(users.isEmpty) {
                return const Center(child: Text('No employees match this filter.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(user.fullName),
                      onTap: () {
                         Navigator.pushNamed(context, '/timesheet_details', arguments: {'id': user.uid, 'name': user.fullName});
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getScreenTitle() {
    switch (widget.filter) {
      case EmployeeFilter.lockedIn: return 'Currently Locked In';
      case EmployeeFilter.lockedOut: return 'Locked Out Today';
      case EmployeeFilter.late: return 'Late Today';
    }
  }
}