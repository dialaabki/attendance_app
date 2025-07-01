import 'package:attendance_app/core/common_widgets/hr_page_shell.dart'; // <-- Import the HR shell
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/usecases/get_current_user.dart';
import 'package:attendance_app/features/attendance/business/entities/attendance_record_entity.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_employee_timesheet.dart';
import 'package:attendance_app/features/attendance/presentation/widgets/timesheet_view.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:flutter/material.dart';

class HrTimesheetPage extends StatefulWidget {
  const HrTimesheetPage({super.key});
  @override
  _HrTimesheetPageState createState() => _HrTimesheetPageState();
}

class _HrTimesheetPageState extends State<HrTimesheetPage> {
  // All state and logic is identical to the employee page
  List<DateTime> _dateRange = [];
  DateTime _selectedDate = DateTime.now();
  AttendanceRecordEntity? _attendanceData;
  bool _isLoading = true;
  String? _userId;
  String _userName = "HR";

  @override
  void initState() {
    super.initState();
    _generateDateRange();
    _initializePage();
  }

  void _generateDateRange() {
    final today = DateTime.now();
    _dateRange = List.generate(14, (index) => today.subtract(Duration(days: index)));
  }

  Future<void> _initializePage() async {
    final getCurrentUser = sl<GetCurrentUser>();
    final userResult = await getCurrentUser(NoParams());

    if(!mounted) return;

    userResult.fold(
      (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red));
      },
      (user) {
        setState(() {
          _userId = user.uid;
          _userName = user.fullName.split(" ")[0];
        });
        _fetchAttendanceDataForDate(_selectedDate);
      },
    );
  }

  Future<void> _fetchAttendanceDataForDate(DateTime date) async {
    if (_userId == null) return;
    setState(() {
      _isLoading = true;
      _selectedDate = date;
      _attendanceData = null;
    });

    final getTimesheet = sl<GetEmployeeTimesheet>();
    final params = TimesheetParams(userId: _userId!, date: date);
    final result = await getTimesheet(params);

    if (mounted) {
      result.fold(
        (failure) => setState(() => _isLoading = false),
        (record) => setState(() {
          _attendanceData = record;
          _isLoading = false;
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HrPageShell( 
      selectedNavIndex: 2, 
      userName: _userName,
      child: TimesheetView(
        isLoading: _isLoading,
        attendanceData: _attendanceData,
        dateRange: _dateRange,
        selectedDate: _selectedDate,
        onDateSelected: _fetchAttendanceDataForDate,
      ),
    );
  }
}