// lib/features/attendance/presentation/widgets/timesheet_view.dart
import 'package:attendance_app/features/attendance/business/entities/attendance_record_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimesheetView extends StatelessWidget {
  final bool isLoading;
  final AttendanceRecordEntity? attendanceData;
  final List<DateTime> dateRange;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const TimesheetView({
    super.key,
    required this.isLoading,
    this.attendanceData,
    required this.dateRange,
    required this.selectedDate,
    required this.onDateSelected,
  });
  
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('h:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dateRange.length,
              itemBuilder: (context, index) {
                final date = dateRange[index];
                bool isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(selectedDate);
                return GestureDetector(
                  onTap: () => onDateSelected(date),
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
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (attendanceData != null)
            Column(
              children: [
                _buildInfoCard(label: 'Clocked In:', value: _formatTimestamp(attendanceData!.clockIn)),
                const SizedBox(height: 15),
                _buildInfoCard(label: 'Clocked Out:', value: _formatTimestamp(attendanceData!.clockOut)),
                const SizedBox(height: 15),
                _buildInfoCard(label: 'Total Break:', value: '${attendanceData!.totalBreakMinutes.toStringAsFixed(0)} minutes'),
                const SizedBox(height: 15),
                _buildInfoCard(label: 'Total Work:', value: attendanceData!.totalDuration ?? 'N/A'),
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