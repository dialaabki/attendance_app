import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class LeaveRequestEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String requestType; // "Vacation" or "Sick Leave"
  final DateTime date;
  final String reason;
  final String status; // "Pending", "Approved", "Declined"
  final Timestamp submittedAt;

  const LeaveRequestEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.requestType,
    required this.date,
    required this.reason,
    required this.status,
    required this.submittedAt,
  });

  @override
  List<Object?> get props => [id, status];
}