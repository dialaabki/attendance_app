import 'package:attendance_app/core/common_widgets/employee_page_shell.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/auth/business/usecases/get_current_user.dart';
import 'package:attendance_app/features/attendance/business/entities/attendance_record_entity.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_employee_timesheet.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeTimesheetPage extends StatefulWidget {
  const EmployeeTimesheetPage({super.key});
  @override
  _EmployeeTimesheetPageState createState() => _EmployeeTimesheetPageState();
}

class _EmployeeTimesheetPageState extends State<EmployeeTimesheetPage> {
  List<DateTime> _dateRange = [];
  DateTime _selectedDate = DateTime.now();
  AttendanceRecordEntity? _attendanceData;
  bool _isLoading = true;
  String? _userId;
  String _userName = "User";

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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('h:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return EmployeePageShell(
      selectedNavIndex: 1,
      userName: _userName,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dateRange.length,
                itemBuilder: (context, index) {
                  final date = _dateRange[index];
                  bool isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
                  return GestureDetector(
                    onTap: () => _fetchAttendanceDataForDate(date),
                    child: _buildDateChip(
                      day: DateFormat('E').format(date),
                      date: DateFormat('d').format(date),
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_attendanceData != null)
              Column(
                children: [
                  _buildInfoCard(label: 'Clocked In:', value: _formatTimestamp(_attendanceData!.clockIn)),
                  const SizedBox(height: 15),
                  _buildInfoCard(label: 'Clocked Out:', value: _formatTimestamp(_attendanceData!.clockOut)),
                  const SizedBox(height: 15),
                  _buildInfoCard(label: 'Total Break:', value: '${_attendanceData!.totalBreakMinutes.toStringAsFixed(0)} minutes'),
                  const SizedBox(height: 15),
                  _buildInfoCard(label: 'Total Work:', value: _attendanceData!.totalDuration ?? 'N/A'),
                ],
              )
            else
              const Expanded(
                child: Center(
                  child: Text('No attendance data for this day.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip({required String day, required String date, required bool isSelected}) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: isSelected ? Colors.black87 : Colors.grey[200], borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String label, required String value}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}