import 'package:attendance_app/features/attendance/business/entities/attendance_record_entity.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_employee_timesheet.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimesheetDetailsPage extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const TimesheetDetailsPage({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<TimesheetDetailsPage> createState() => _TimesheetDetailsPageState();
}

class _TimesheetDetailsPageState extends State<TimesheetDetailsPage> {
  List<DateTime> _dateRange = [];
  DateTime _selectedDate = DateTime.now();
  AttendanceRecordEntity? _attendanceData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateDateRange();
    _fetchAttendanceDataForDate(_selectedDate);
  }

  void _generateDateRange() {
    final today = DateTime.now();
    _dateRange = List.generate(30, (index) => today.subtract(Duration(days: index))).reversed.toList();
  }

  Future<void> _fetchAttendanceDataForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _selectedDate = date;
      _attendanceData = null;
    });

    final getTimesheet = sl<GetEmployeeTimesheet>();
    final params = TimesheetParams(userId: widget.employeeId, date: date);
    final result = await getTimesheet(params);
    
    if(mounted) {
      result.fold(
        (failure) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red));
        },
        (record) => setState(() {
          _attendanceData = record;
          _isLoading = false;
        })
      );
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('h:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDAC844);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.employeeName, style: const TextStyle(fontFamily: 'Serif', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(Icons.person, size: 30, color: primaryColor)),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _dateRange.length,
                  controller: ScrollController(initialScrollOffset: (_dateRange.length * 76.0) - MediaQuery.of(context).size.width),
                  itemBuilder: (context, index) {
                    final date = _dateRange[index];
                    bool isSelected = DateFormat('yMd').format(date) == DateFormat('yMd').format(_selectedDate);
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
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _attendanceData != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Column(
                            children: [
                              _buildInfoCard(label: 'Clocked In:', value: _formatTimestamp(_attendanceData!.clockIn)),
                              const SizedBox(height: 15),
                              _buildInfoCard(label: 'Clocked Out:', value: _formatTimestamp(_attendanceData!.clockOut)),
                              const SizedBox(height: 15),
                              _buildInfoCard(label: 'Total Break:', value: '${_attendanceData!.totalBreakMinutes.toStringAsFixed(0)} minutes'),
                              const SizedBox(height: 15),
                              _buildInfoCard(label: 'Total Work:', value: _attendanceData!.totalDuration ?? 'N/A'),
                            ],
                          ),
                        )
                      : const Center(child: Text('No attendance data for this day.', style: TextStyle(fontSize: 18, color: Colors.grey))),
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
      decoration: BoxDecoration(
        color: isSelected ? Colors.black87 : Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
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