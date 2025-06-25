import 'package:attendance_app/core/common_widgets/employee_page_shell.dart';
import 'package:attendance_app/core/common_widgets/hr_page_shell.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/auth/business/usecases/get_current_user.dart';
import 'package:attendance_app/features/attendance/business/usecases/clock_in.dart';
import 'package:attendance_app/features/attendance/business/usecases/clock_out.dart';
import 'package:attendance_app/features/attendance/business/usecases/get_today_attendance.dart';
import 'package:attendance_app/features/attendance/business/usecases/start_break.dart';
import 'package:attendance_app/features/attendance/business/usecases/end_break.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:flutter/material.dart';

class EmployeeHomePage extends StatefulWidget {
  final bool isHr;
  
  const EmployeeHomePage({super.key, this.isHr = false});
  
  @override
  _EmployeeHomePageState createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  UserEntity? _currentUser;
  bool _isClockedIn = false;
  bool _isOnBreak = false;
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _isBreakProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    final getCurrentUser = sl<GetCurrentUser>();
    final userResult = await getCurrentUser(NoParams());

    if (!mounted) return;

    userResult.fold(
      (failure) {
        setState(() => _isLoading = false);
        _showSnackBar(failure.message, isError: true);
      },
      (user) {
        setState(() {
          _currentUser = user;
        });
        _getTodayStatus();
      },
    );
  }

  Future<void> _getTodayStatus() async {
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    final getTodayAttendance = sl<GetTodayAttendance>();
    final result = await getTodayAttendance(_currentUser!.uid);

    if (mounted) {
      result.fold(
        (failure) {
          _showSnackBar(failure.message, isError: true);
        },
        (record) {
          setState(() {
            _isClockedIn = record != null && record.clockOut == null;
            _isOnBreak = record?.isOnBreak ?? false;
          });
        },
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleClockAction() async {
    if (_currentUser == null) return;
    
    setState(() => _isProcessing = true);

    final result = _isClockedIn 
      ? await sl<ClockOut>()(_currentUser!)
      : await sl<ClockIn>()(_currentUser!);
    
    if (mounted) {
      result.fold(
        (failure) => _showSnackBar(failure.message, isError: true),
        (_) {
          _showSnackBar('Clocked ${_isClockedIn ? "Out" : "In"} successfully!');
          setState(() => _isClockedIn = !_isClockedIn);
        },
      );
      setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _handleBreakAction() async {
    if (_currentUser == null) return;
    
    setState(() => _isBreakProcessing = true);

    final result = _isOnBreak
        ? await sl<EndBreak>()(_currentUser!.uid)
        : await sl<StartBreak>()(_currentUser!.uid);
    
    if (mounted) {
      result.fold(
        (failure) => _showSnackBar(failure.message, isError: true),
        (_) {
          _showSnackBar('You are now ${!_isOnBreak ? "on" : "off"} break.');
          setState(() => _isOnBreak = !_isOnBreak);
        },
      );
      setState(() => _isBreakProcessing = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message), 
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600
    ));
  }

  Widget _buildContent() {
    final String clockButtonText = _isClockedIn ? 'Clock out' : 'Clock in';
    final Color clockButtonColor = _isClockedIn ? Colors.red.shade400 : Colors.green.shade500;
    
    final String breakButtonText = _isOnBreak ? 'End Break' : 'Start Break';
    final Color breakButtonColor = _isOnBreak ? Colors.orange.shade600 : Colors.blue.shade500;

    return _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _isClockedIn ? (_isOnBreak ? 'You are currently on break' : 'You are currently clocked in') : 'You are currently clocked out',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 220,
                height: 220,
                child: ElevatedButton(
                  onPressed: _isProcessing || _isOnBreak ? null : _handleClockAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: clockButtonColor, 
                    shape: const CircleBorder(), 
                    elevation: 10, 
                    shadowColor: clockButtonColor.withOpacity(0.4)
                  ),
                  child: _isProcessing 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(clockButtonText, style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),

              if (_isClockedIn)
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: _isBreakProcessing ? null : _handleBreakAction,
                    icon: _isBreakProcessing 
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : Icon(_isOnBreak ? Icons.play_arrow : Icons.pause),
                    label: Text(breakButtonText, style: const TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: breakButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
            ],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final String userNameForShell = _currentUser?.fullName.split(' ')[0] ?? 'User';

    if (widget.isHr) {
      return HrPageShell(
        selectedNavIndex: 0,
        userName: userNameForShell,
        child: _buildContent(),
      );
    }

    return EmployeePageShell(
      selectedNavIndex: 0,
      userName: userNameForShell,
      child: _buildContent(),
    );
  }
}