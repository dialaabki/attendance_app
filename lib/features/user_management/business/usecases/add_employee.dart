import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/user_management/business/repositories/user_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AddEmployee implements UseCase<void, AddEmployeeParams> {
  final UserManagementRepository repository;
  AddEmployee(this.repository);

  @override
  Future<Either<Failure, void>> call(AddEmployeeParams params) async {
    return await repository.addEmployee(params);
  }
}

class AddEmployeeParams extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String type;
  final Set<String> standardWorkDays;
  final TimeOfDay standardStartTime;
  final TimeOfDay standardEndTime;
  final String locationName;
  final double latitude;
  final double longitude;
  final List<CustomScheduleEntity> customSchedules;
  final double salary;
  final List<LeaveBalanceEntity> leaveBalances;

  const AddEmployeeParams({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    required this.type,
    required this.standardWorkDays,
    required this.standardStartTime,
    required this.standardEndTime,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.customSchedules,
    required this.salary,
    required this.leaveBalances,
  });

  @override
  List<Object?> get props => [
    email, fullName, role, type, locationName, latitude, longitude, customSchedules, salary, leaveBalances
  ];
}