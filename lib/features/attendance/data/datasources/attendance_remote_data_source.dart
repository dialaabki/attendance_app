import 'package:attendance_app/core/errors/exceptions.dart';
import 'package:attendance_app/features/auth/data/models/user_model.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_filtered_employees.dart';
import 'package:attendance_app/features/attendance/data/models/attendance_record_model.dart';
import 'package:attendance_app/features/attendance/data/models/daily_stats_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

abstract class AttendanceRemoteDataSource {
  Future<void> clockIn(String userId);
  Future<void> clockOut(String userId);
  Future<void> startBreak(String userId);
  Future<void> endBreak(String userId);
  Future<AttendanceRecordModel?> getTodayAttendance(String userId);
  Future<AttendanceRecordModel?> getEmployeeTimesheetForDate(String userId, DateTime date);
  Future<DailyStatsModel> getDailyStats(DateTime date);
  Future<List<UserModel>> getFilteredEmployees(EmployeeFilterParams params);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AttendanceRemoteDataSourceImpl({required this.firestore, required this.auth});

  String _getDocId(String userId, DateTime date) => '${userId}_${DateFormat('yyyy-MM-dd').format(date)}';
  
  @override
  Future<void> clockIn(String userId) async {
    final now = DateTime.now();
    final docId = _getDocId(userId, now);
    final attendanceData = {
      'userId': userId,
      'date': DateFormat('yyyy-MM-dd').format(now),
      'clockIn': Timestamp.fromDate(now),
      'clockOut': null,
      'totalDuration': null,
      'breaks': [],
      'totalBreakMinutes': 0.0,
    };
    try {
      await firestore.collection('attendance').doc(docId).set(attendanceData);
    } catch(e) {
      throw ServerException('Failed to clock in. Please try again.');
    }
  }

  @override
  Future<void> clockOut(String userId) async {
    final now = DateTime.now();
    final docId = _getDocId(userId, now);
    final docRef = firestore.collection('attendance').doc(docId);
    
    try {
      final doc = await docRef.get();
      if (doc.exists && doc.data()?['clockIn'] != null) {
        final clockInTime = (doc.data()!['clockIn'] as Timestamp).toDate();
        final duration = now.difference(clockInTime);
        await docRef.update({
          'clockOut': Timestamp.fromDate(now),
          'totalDuration': '${duration.inHours}h ${duration.inMinutes.remainder(60)}m',
        });
      } else {
        throw ServerException('Clock-in record not found. Cannot clock out.');
      }
    } catch (e) {
      throw ServerException('Failed to clock out. Please try again.');
    }
  }
  
  @override
  Future<void> startBreak(String userId) async {
    final now = DateTime.now();
    final docId = _getDocId(userId, now);
    final docRef = firestore.collection('attendance').doc(docId);

    final newBreak = {
      'start': Timestamp.fromDate(now),
      'end': null,
    };

    try {
      await docRef.update({
        'breaks': FieldValue.arrayUnion([newBreak])
      });
    } catch (e) {
      throw ServerException('Failed to start break. Please try again.');
    }
  }

  @override
  Future<void> endBreak(String userId) async {
    final now = DateTime.now();
    final docId = _getDocId(userId, now);
    final docRef = firestore.collection('attendance').doc(docId);

    try {
      // Step 1: Read the document first.
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception("Cannot end break: Today's attendance record not found.");
      }

      // Step 2: Prepare the updates in Dart.
      final data = docSnapshot.data()!;
      final breaks = List<Map<String, dynamic>>.from(data['breaks'] ?? []);
      
      int openBreakIndex = breaks.indexWhere((b) => b['end'] == null);

      if (openBreakIndex == -1) {
        throw Exception("No active break found to end.");
      }

      breaks[openBreakIndex]['end'] = Timestamp.fromDate(now);

      double totalMinutes = 0.0;
      for (var b in breaks) {
        if (b['start'] != null && b['end'] != null) {
          final start = (b['start'] as Timestamp).toDate();
          final end = (b['end'] as Timestamp).toDate();
          totalMinutes += end.difference(start).inMilliseconds / (1000 * 60);
        }
      }

      // Step 3: Write the prepared updates back to Firestore.
      await docRef.update({
        'breaks': breaks,
        'totalBreakMinutes': totalMinutes,
      });

    } catch (e) {
      throw ServerException('Failed to end break: ${e.toString()}');
    }
  }

  @override
  Future<AttendanceRecordModel?> getTodayAttendance(String userId) async {
    final docId = _getDocId(userId, DateTime.now());
    final doc = await firestore.collection('attendance').doc(docId).get();
    return doc.exists ? AttendanceRecordModel.fromFirestore(doc) : null;
  }
  
  @override
  Future<AttendanceRecordModel?> getEmployeeTimesheetForDate(String userId, DateTime date) async {
    final docId = _getDocId(userId, date);
    final doc = await firestore.collection('attendance').doc(docId).get();
    return doc.exists ? AttendanceRecordModel.fromFirestore(doc) : null;
  }

  @override
  Future<DailyStatsModel> getDailyStats(DateTime date) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final snapshot = await firestore.collection('attendance').where('date', isEqualTo: dateString).get();

      int lockedIn = 0;
      int lockedOut = 0;
      int lateCount = 0;
      final lateThreshold = DateTime(date.year, date.month, date.day, 9, 5);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['clockIn'] != null) {
          if (data['clockOut'] == null) {
            lockedIn++;
          } else {
            lockedOut++;
          }
          if ((data['clockIn'] as Timestamp).toDate().isAfter(lateThreshold)) {
            lateCount++;
          }
        }
      }
      return DailyStatsModel(lockedIn: lockedIn, lockedOut: lockedOut, late: lateCount);
    } catch (e) {
      throw ServerException('Failed to fetch daily statistics.');
    }
  }

  @override
  Future<List<UserModel>> getFilteredEmployees(EmployeeFilterParams params) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(params.date);
      Query query = firestore.collection('attendance').where('date', isEqualTo: dateString);

      switch (params.filter) {
        case EmployeeFilter.lockedIn:
          query = query.where('clockOut', isNull: true);
          break;
        case EmployeeFilter.lockedOut:
          query = query.where('clockOut', isNotEqualTo: null);
          break;
        case EmployeeFilter.late:
          final lateThreshold = DateTime(params.date.year, params.date.month, params.date.day, 9, 5);
          query = query.where('clockIn', isGreaterThan: Timestamp.fromDate(lateThreshold));
          break;
      }

      final attendanceSnapshot = await query.get();
      
      final userIds = attendanceSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['userId'] as String?;
      }).where((id) => id != null).cast<String>().toSet().toList();

      if (userIds.isEmpty) return [];

      final usersSnapshot = await firestore.collection('users').where(FieldPath.documentId, whereIn: userIds).get();
      
      return usersSnapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch(e) {
      throw ServerException('Failed to retrieve filtered employees.');
    }
  }
}