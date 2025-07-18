import 'package:attendance_app/features/auth/business/repositories/auth_repository.dart';
import 'package:attendance_app/features/auth/business/usecases/get_current_user.dart';
import 'package:attendance_app/features/auth/business/usecases/login_user.dart';
import 'package:attendance_app/features/auth/business/usecases/logout_user.dart';
import 'package:attendance_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attendance_app/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:attendance_app/features/user_management/business/repositories/user_management_repository.dart';
import 'package:attendance_app/features/user_management/business/usecases/add_employee.dart';
import 'package:attendance_app/features/user_management/business/usecases/get_all_employees.dart';
import 'package:attendance_app/features/user_management/data/datasources/user_management_remote_data_source.dart';
import 'package:attendance_app/features/user_management/data/repositories/user_management_repository_impl.dart';

import 'package:attendance_app/features/attendance/business/repositories/attendance_repository.dart';
import 'package:attendance_app/features/attendance/business/repositories/location_repository.dart';
import 'package:attendance_app/features/attendance/business/usecases/clock_in.dart';
import 'package:attendance_app/features/attendance/business/usecases/clock_out.dart';
import 'package:attendance_app/features/attendance/business/usecases/start_break.dart';
import 'package:attendance_app/features/attendance/business/usecases/end_break.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_daily_stats.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_employee_timesheet.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_filtered_employees.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_today_attendance.dart';
import 'package:attendance_app/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:attendance_app/features/attendance/data/datasources/location_local_data_source.dart';
import 'package:attendance_app/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:attendance_app/features/attendance/data/repositories/location_repository_impl.dart';

// --- ADD THESE IMPORTS FOR THE NEW FEATURE ---
import 'package:attendance_app/features/leave_management/business/repositories/leave_management_repository.dart';
import 'package:attendance_app/features/leave_management/business/usecases/get_hr_requests.dart';
import 'package:attendance_app/features/leave_management/business/usecases/get_my_requests.dart';
import 'package:attendance_app/features/leave_management/business/usecases/submit_request.dart';
import 'package:attendance_app/features/leave_management/business/usecases/update_request_status.dart';
import 'package:attendance_app/features/leave_management/data/datasources/leave_management_remote_data_source.dart';
import 'package:attendance_app/features/leave_management/data/repositories/leave_management_repository_impl.dart';
// ------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Use Cases - Auth
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  
  // Use Cases - User Management
  sl.registerLazySingleton(() => AddEmployee(sl()));
  sl.registerLazySingleton(() => GetAllEmployees(sl()));
  
  // Use Cases - Attendance
  sl.registerLazySingleton(() => ClockIn(sl(), sl()));
  sl.registerLazySingleton(() => ClockOut(sl(), sl()));
  sl.registerLazySingleton(() => StartBreak(sl()));
  sl.registerLazySingleton(() => EndBreak(sl()));
  sl.registerLazySingleton(() => GetTodayAttendance(sl()));
  sl.registerLazySingleton(() => GetEmployeeTimesheet(sl()));
  sl.registerLazySingleton(() => GetDailyStats(sl()));
  sl.registerLazySingleton(() => GetFilteredEmployees(sl()));

  // --- THIS IS THE FIX ---
  // Use Cases - Leave Management
  sl.registerLazySingleton(() => SubmitRequest(sl()));
  sl.registerLazySingleton(() => GetMyRequests(sl()));
  sl.registerLazySingleton(() => GetHrRequests(sl()));
  sl.registerLazySingleton(() => UpdateRequestStatus(sl()));
  // -------------------------

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<UserManagementRepository>(() => UserManagementRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AttendanceRepository>(() => AttendanceRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl(dataSource: sl()));
  
  // --- THIS IS THE FIX ---
  sl.registerLazySingleton<LeaveManagementRepository>(() => LeaveManagementRepositoryImpl(remoteDataSource: sl()));
  // -------------------------

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()));
  sl.registerLazySingleton<UserManagementRemoteDataSource>(() => UserManagementRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()));
  sl.registerLazySingleton<AttendanceRemoteDataSource>(() => AttendanceRemoteDataSourceImpl(firestore: sl(), auth: sl()));
  sl.registerLazySingleton<LocationLocalDataSource>(() => LocationLocalDataSourceImpl());

  // --- THIS IS THE FIX ---
  sl.registerLazySingleton<LeaveManagementRemoteDataSource>(() => LeaveManagementRemoteDataSourceImpl(firestore: sl()));
  // --------------------------

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}