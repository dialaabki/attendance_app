import 'package:attendance_app/core/common_widgets/hr_page_shell.dart';
import 'package:attendance_app/features/auth/presentation/pages/login_page.dart';
import 'package:attendance_app/features/user_management/presentation/pages/add_employee_page.dart';
import 'package:attendance_app/features/user_management/presentation/pages/admin_profile_page.dart';
import 'package:attendance_app/features/user_management/presentation/pages/employees_page.dart';
import 'package:attendance_app/features/user_management/presentation/pages/employee_profile_page.dart';
import 'package:attendance_app/features/attendance/presentation/pages/admin_home_page.dart';
import 'package:attendance_app/features/attendance/presentation/pages/employee_home_page.dart';
import 'package:attendance_app/features/attendance/presentation/pages/employee_timesheet_page.dart';
import 'package:attendance_app/features/attendance/presentation/pages/filtered_employee_list_page.dart';
import 'package:attendance_app/features/attendance/presentation/pages/timesheet_details_page.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_filtered_employees.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFDAC844),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/login',
      routes: {
        // Auth
        '/login': (context) => const LoginPage(),

        // Admin Routes
        '/admin_home': (context) => const AdminHomePage(),
        '/employees': (context) => const EmployeesPage(),
        '/add_employee': (context) => const AddEmployeePage(),
        '/admin_profile': (context) => const AdminProfilePage(),
        '/timesheet_details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return TimesheetDetailsPage(employeeId: args['id'], employeeName: args['name']);
        },
        '/filtered_employees': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return FilteredEmployeeListPage(filter: args['filter'], date: args['date']);
        },

        // Employee Routes
        '/employee_home': (context) => const EmployeeHomePage(),
        '/employee_timesheet': (context) => const EmployeeTimesheetPage(),
        '/employee_profile': (context) => const EmployeeProfilePage(),

        // --- HR ROUTES ---
        '/hr_home': (context) => const EmployeeHomePage(isHr: true), 
        '/hr_profile': (context) => const EmployeeProfilePage(isHr: true),
      },
    );
  }
}