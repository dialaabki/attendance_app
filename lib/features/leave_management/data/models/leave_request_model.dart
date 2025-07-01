import 'package:attendance_app/features/leave_management/business/entities/leave_request_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequestModel extends LeaveRequestEntity {
  const LeaveRequestModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.requestType,
    required super.date,
    required super.reason,
    required super.status,
    required super.submittedAt,
  });

  factory LeaveRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaveRequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      requestType: data['requestType'] ?? 'Unknown',
      // Safely parse the Timestamp and provide a default if it's missing
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reason: data['reason'] ?? 'No reason provided.',
      status: data['status'] ?? 'Pending',
      submittedAt: data['submittedAt'] ?? Timestamp.now(),
    );
  }
}