import 'package:attendance_app/core/errors/exceptions.dart';
import 'package:attendance_app/core/services/notification_service.dart'; 
import 'package:attendance_app/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
 // final NotificationService notificationService;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
   // required this.notificationService,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user == null) {
        throw ServerException('Login failed, please try again.');
      }

     /* final String? token = await notificationService.getDeviceToken();
      if (token != null) {
       
        await firestore.collection('users').doc(credential.user!.uid).set(
          { 'deviceToken': token },
          SetOptions(merge: true),
        );
      }
*/
      return await _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'An unknown auth error occurred.');
    } catch (e) {
      throw ServerException('An unexpected error occurred.');
    }
  }

  @override
  Future<void> logout() async {
  
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw ServerException('No user is currently signed in.');
    }
    return await _getUserFromFirestore(user.uid);
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw ServerException('User data not found in the database.');
    }
    return UserModel.fromFirestore(doc);
  }
}