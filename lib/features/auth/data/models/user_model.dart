import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

TimeOfDay _parseTimeOfDay(String time) {
  try {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  } catch (e) {
    return const TimeOfDay(hour: 9, minute: 0);
  }
}

class CustomScheduleModel extends CustomScheduleEntity {
  const CustomScheduleModel({required super.day, required super.startTime, required super.endTime});
  
  factory CustomScheduleModel.fromMap(Map<String, dynamic> map) {
    return CustomScheduleModel(
      day: map['day'] ?? 'Mon',
      startTime: _parseTimeOfDay(map['startTime'] ?? '09:00'),
      endTime: _parseTimeOfDay(map['endTime'] ?? '17:00'),
    );
  }

  Map<String, String> toMap() {
    return {
      'day': day,
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
    };
  }
}

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.role,
    required super.type,
    required super.standardWorkDays,
    required super.standardStartTime,
    required super.standardEndTime,
    required super.locationName,
    required super.latitude,
    required super.longitude,
    required super.customSchedules,
    required super.salary,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final List<CustomScheduleEntity> schedules = (data['customSchedules'] as List<dynamic>?)
        ?.map((scheduleMap) => CustomScheduleModel.fromMap(scheduleMap as Map<String, dynamic>))
        .toList() ?? [];

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? 'No Name',
      role: data['role'] ?? 'Employee',
      type: data['type'] ?? 'N/A',
      standardWorkDays: List<String>.from(data['standardWorkDays'] ?? []),
      standardStartTime: _parseTimeOfDay(data['standardStartTime'] ?? '09:00'),
      standardEndTime: _parseTimeOfDay(data['standardEndTime'] ?? '18:00'),
      locationName: data['locationName'] ?? 'Main Office',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      customSchedules: schedules,
      salary: (data['salary'] as num?)?.toDouble() ?? 0.0,
    );
  }
}