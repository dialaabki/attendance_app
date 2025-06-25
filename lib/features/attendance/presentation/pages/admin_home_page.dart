import 'package:attendance_app/core/common_widgets/admin_page_shell.dart';
import 'package:attendance_app/features/attendance/business/entities/daily_stats_entity.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_daily_stats.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_filtered_employees.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<DateTime> _dateRange = [];
  DateTime _selectedDate = DateTime.now();
  DailyStatsEntity? _dailyStats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateDateRange();
    _fetchStatsForDate(_selectedDate);
  }

  void _generateDateRange() {
    final today = DateTime.now();
    _dateRange = List.generate(7, (index) => today.subtract(Duration(days: index))).reversed.toList();
  }

  Future<void> _fetchStatsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _selectedDate = date;
      _errorMessage = null;
    });

    final getDailyStats = sl<GetDailyStats>();
    final result = await getDailyStats(date);

    if(mounted) {
      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
        (stats) {
          setState(() {
            _dailyStats = stats;
            _isLoading = false;
          });
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Dashboard',
      selectedNavIndex: 1,
      showBackButton: false,
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
                    onTap: () => _fetchStatsForDate(date),
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
            else if (_errorMessage != null)
               Expanded(child: Center(child: Text(_errorMessage!)))
            else if (_dailyStats != null)
              Column(
                children: [
                  _buildSummaryCard('${_dailyStats!.lockedIn} LOCKED IN', EmployeeFilter.lockedIn),
                  const SizedBox(height: 15),
                  _buildSummaryCard('${_dailyStats!.lockedOut} LOCKED OUT', EmployeeFilter.lockedOut),
                  const SizedBox(height: 15),
                  _buildSummaryCard('${_dailyStats!.late} LATE', EmployeeFilter.late),
                ],
              )
            else
              const Expanded(child: Center(child: Text("No data available."))),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip({required String day, required String date, required bool isSelected}) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black87 : Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 1, blurRadius: 5)] : [],
      ),
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

  Widget _buildSummaryCard(String text, EmployeeFilter filter) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/filtered_employees',
          arguments: {'filter': filter, 'date': _selectedDate},
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
        child: Center(child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54))),
      ),
    );
  }
}