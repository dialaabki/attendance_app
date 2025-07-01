import 'package:attendance_app/core/common_widgets/employee_page_shell.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:attendance_app/features/auth/business/usecases/get_current_user.dart';
import 'package:attendance_app/features/leave_management/business/entities/leave_request_entity.dart';
import 'package:attendance_app/features/leave_management/business/usecases/get_my_requests.dart';
import 'package:attendance_app/features/leave_management/business/usecases/submit_request.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyBenefitsPage extends StatefulWidget {
  const MyBenefitsPage({super.key});

  @override
  State<MyBenefitsPage> createState() => _MyBenefitsPageState();
}

class _MyBenefitsPageState extends State<MyBenefitsPage> {
  UserEntity? _currentUser;
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  String _selectedRequestType = 'Vacation';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  // Stream for the history and balance sections
  Stream<dartz.Either<dynamic, List<LeaveRequestEntity>>>? _requestsStream;

  // Constants for total leave days
  final int _totalVacationDays = 14;
  final int _totalSickDays = 14;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() async {
    final result = await sl<GetCurrentUser>()(NoParams());
    if (mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red));
        },
        (user) {
          setState(() {
            _currentUser = user;
            // Initialize the stream here, once, so it can be reused
            _requestsStream = sl<GetMyRequests>().watch(user.uid);
          });
        },
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // Allow requesting for recent past (e.g., sick leave)
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitRequest() async {
    if (_currentUser == null || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);

    final params = SubmitRequestParams(
      userId: _currentUser!.uid,
      userName: _currentUser!.fullName,
      requestType: _selectedRequestType,
      date: _selectedDate,
      reason: _reasonController.text.trim(),
    );

    final result = await sl<SubmitRequest>()(params);

    if (mounted) {
       result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red));
        },
        (_) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted successfully!'), backgroundColor: Colors.green));
           _reasonController.clear();
        }
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmployeePageShell(
      selectedNavIndex: 2, // Corresponds to 'My Benefits'
      userName: _currentUser?.fullName.split(' ')[0] ?? "User",
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildBalanceSection(),
          const SizedBox(height: 24),
          _buildRequestForm(),
          const SizedBox(height: 24),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    return StreamBuilder<dartz.Either<dynamic, List<LeaveRequestEntity>>>(
      stream: _requestsStream,
      builder: (context, snapshot) {
        int approvedVacations = 0;
        int approvedSickLeaves = 0;

        if (snapshot.hasData) {
          snapshot.data!.fold(
            (l) => null, // Left (failure) case
            (requests) {
              approvedVacations = requests.where((r) => r.requestType == 'Vacation' && r.status == 'Approved').length;
              approvedSickLeaves = requests.where((r) => r.requestType == 'Sick Leave' && r.status == 'Approved').length;
            }
          );
        }

        int remainingVacations = _totalVacationDays - approvedVacations;
        int remainingSickLeaves = _totalSickDays - approvedSickLeaves;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Leave Balances", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _balanceItem(Icons.beach_access_rounded, "Vacations Left", remainingVacations, Colors.blue),
                    _balanceItem(Icons.sick_rounded, "Sick Leaves Left", remainingSickLeaves, Colors.red),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _balanceItem(IconData icon, String label, int days, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text("$days", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildRequestForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("New Leave/Vacation Request", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRequestType,
                items: ['Vacation', 'Sick Leave']
                    .map((label) => DropdownMenuItem(child: Text(label), value: label))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRequestType = value);
                },
                decoration: InputDecoration(labelText: 'Request Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: ListTile(
                  title: Text("Date: ${DateFormat.yMMMd().format(_selectedDate)}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(labelText: 'Reason for request', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                maxLines: 3,
                validator: (value) => (value?.isEmpty ?? true) ? 'Please provide a reason' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  onPressed: _isSubmitting ? null : _submitRequest,
                  label: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Submit Request"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_requestsStream == null) {
      return const Center(child: Text("Initializing..."));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text("Request History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        StreamBuilder<dartz.Either<dynamic, List<LeaveRequestEntity>>>(
          stream: _requestsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("No requests found."));
            }

            return snapshot.data!.fold(
              (failure) => Center(child: Text('Error: ${failure.toString()}')),
              (requests) {
                if (requests.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("You haven't submitted any requests yet.", textAlign: TextAlign.center),
                  ));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: _getStatusIcon(request.status),
                        title: Text("${request.requestType} on ${DateFormat.yMMMd().format(request.date)}"),
                        subtitle: Text(request.reason, maxLines: 2, overflow: TextOverflow.ellipsis,),
                        trailing: Text(request.status, style: TextStyle(color: _getStatusColor(request.status), fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Declined':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_empty_rounded, color: Colors.orange);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Declined':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}