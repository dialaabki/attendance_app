import 'package:attendance_app/features/attendance/business/entities/attendance_record_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BreakModel extends BreakEntity {
  const BreakModel({required super.start, super.end});

  factory BreakModel.fromMap(Map<String, dynamic> map) {
    return BreakModel(
      start: map['start'] as Timestamp,
      end: map['end'] as Timestamp?,
    );
  }
}

class AttendanceRecordModel extends AttendanceRecordEntity {
  const AttendanceRecordModel({
    required super.userId,
    required super.date,
    super.clockIn,
    super.clockOut,
    super.totalDuration,
    required super.breaks,
    required super.totalBreakMinutes,
  });

  factory AttendanceRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AttendanceRecordModel(
      userId: data['userId'],
      date: data['date'],
      clockIn: data['clockIn'],
      clockOut: data['clockOut'],
      totalDuration: data['totalDuration'],
      breaks: List<Map<String, dynamic>>.from(data['breaks'] ?? []),
      totalBreakMinutes: (data['totalBreakMinutes'] as num?)?.toDouble() ?? 0.0,
    );
  }
}