import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CustomScheduleEntity extends Equatable {
  final String day;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const CustomScheduleEntity({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [day, startTime, endTime];
}


class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final String type;
  final List<String> standardWorkDays;
  final TimeOfDay standardStartTime;
  final TimeOfDay standardEndTime;
  final String locationName;
  final double latitude;
  final double longitude;
  final List<CustomScheduleEntity> customSchedules;
  final double salary;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.fullName,
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
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        fullName,
        role,
        type,
        standardWorkDays,
        standardStartTime,
        standardEndTime,
        locationName,
        latitude,
        longitude,
        customSchedules,
        salary,
      ];
}