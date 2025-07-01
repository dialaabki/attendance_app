import 'package:attendance_app/core/errors/exceptions.dart';
import 'package:attendance_app/features/leave_management/business/usecases/submit_request.dart';
import 'package:attendance_app/features/leave_management/data/models/leave_request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class LeaveManagementRemoteDataSource {
  Future<void> submitRequest(SubmitRequestParams params);
  Stream<List<LeaveRequestModel>> getRequestsForHr();
  Stream<List<LeaveRequestModel>> getMyRequests(String userId);
  Future<void> updateRequestStatus(String requestId, String newStatus);
}

class LeaveManagementRemoteDataSourceImpl implements LeaveManagementRemoteDataSource {
  final FirebaseFirestore firestore;
  LeaveManagementRemoteDataSourceImpl({required this.firestore});

  final _collection = 'leaveRequests';

  @override
  Future<void> submitRequest(SubmitRequestParams params) async {
    final requestData = {
      'userId': params.userId,
      'userName': params.userName,
      'requestType': params.requestType,
      'date': Timestamp.fromDate(params.date),
      'reason': params.reason,
      'status': 'Pending',
      'submittedAt': Timestamp.now(),
    };
    try {
      await firestore.collection(_collection).add(requestData);
    } catch(e) {
      throw ServerException('Failed to submit request.');
    }
  }

  @override
  Stream<List<LeaveRequestModel>> getRequestsForHr() {
    return firestore.collection(_collection)
      .orderBy('submittedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => LeaveRequestModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<LeaveRequestModel>> getMyRequests(String userId) {
    return firestore.collection(_collection)
      .where('userId', isEqualTo: userId)
      .orderBy('submittedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => LeaveRequestModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await firestore.collection(_collection).doc(requestId).update({'status': newStatus});
    } catch(e) {
      throw ServerException('Failed to update request status.');
    }
  }
}