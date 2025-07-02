import 'package:attendance_app/core/errors/exceptions.dart';
import 'package:attendance_app/features/auth/data/models/user_model.dart';
import 'package:attendance_app/features/user_management/business/usecases/add_employee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class UserManagementRemoteDataSource {
  Stream<List<UserModel>> getAllEmployees();
  Future<void> addEmployee(AddEmployeeParams params);
}

class UserManagementRemoteDataSourceImpl implements UserManagementRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  UserManagementRemoteDataSourceImpl({required this.firebaseAuth, required this.firestore});

  @override
  Stream<List<UserModel>> getAllEmployees() {
    try {
      return firestore.collection('users').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw ServerException('Failed to fetch employees.');
    }
  }

  @override
  Future<void> addEmployee(AddEmployeeParams params) async {
    UserCredential? credential;
    FirebaseApp? tempApp;
    try {
      tempApp = await Firebase.initializeApp(
        name: 'temp_app_for_user_creation_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      FirebaseAuth tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      credential = await tempAuth.createUserWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      if (credential.user == null) {
        throw ServerException('Failed to create user in Authentication.');
      }

      final userData = {
        'fullName': params.fullName,
        'email': params.email,
        'role': params.role,
        'type': params.type,
        'standardWorkDays': params.standardWorkDays.toList(),
        'standardStartTime': '${params.standardStartTime.hour.toString().padLeft(2, '0')}:${params.standardStartTime.minute.toString().padLeft(2, '0')}',
        'standardEndTime': '${params.standardEndTime.hour.toString().padLeft(2, '0')}:${params.standardEndTime.minute.toString().padLeft(2, '0')}',
        'locationName': params.locationName,
        'latitude': params.latitude,
        'longitude': params.longitude,
        'customSchedules': params.customSchedules
            .map((schedule) => {
                  'day': schedule.day,
                  'startTime': '${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')}',
                  'endTime': '${schedule.endTime.hour.toString().padLeft(2, '0')}:${schedule.endTime.minute.toString().padLeft(2, '0')}',
                })
            .toList(),
        'salary': params.salary,
        'leaveBalances': params.leaveBalances
            .map((balance) => {
                  'leaveType': balance.leaveType,
                  'totalDays': balance.totalDays,
                })
            .toList(),
      };
      // ---------------------------------

      await firestore.collection('users').doc(credential.user!.uid).set(userData);
    } on FirebaseAuthException catch (e) {
      final cred = credential;
      if (cred != null && cred.user != null) {
        await cred.user!.delete();
      }
      throw ServerException(e.message ?? 'An auth error occurred while adding employee.');
    } catch (e) {
      final cred = credential;
      if (cred != null && cred.user != null) {
        await cred.user!.delete();
      }
      throw ServerException('An unexpected error occurred while adding employee: ${e.toString()}');
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }
}