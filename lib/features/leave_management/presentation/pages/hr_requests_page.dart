import 'package:attendance_app/core/common_widgets/hr_page_shell.dart';
import 'package:attendance_app/core/usecases/usecase.dart';
import 'package:attendance_app/features/auth/business/usecases/get_current_user.dart';
import 'package:attendance_app/features/leave_management/business/entities/leave_request_entity.dart';
import 'package:attendance_app/features/leave_management/business/usecases/get_hr_requests.dart';
import 'package:attendance_app/features/leave_management/business/usecases/update_request_status.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HrRequestsPage extends StatefulWidget {
  const HrRequestsPage({super.key});

  @override
  State<HrRequestsPage> createState() => _HrRequestsPageState();
}

class _HrRequestsPageState extends State<HrRequestsPage> {
  String _userName = "HR";

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  void _fetchCurrentUser() async {
    final result = await sl<GetCurrentUser>()(NoParams());
    result.fold(
      (l) => null, // Handle error
      (user) => setState(() => _userName = user.fullName.split(' ')[0]),
    );
  }
  
  Future<void> _updateStatus(String requestId, String newStatus) async {
    final updateUseCase = sl<UpdateRequestStatus>();
    final params = UpdateRequestParams(requestId: requestId, newStatus: newStatus);
    final result = await updateUseCase(params);

    if (mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red));
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request status updated!'), backgroundColor: Colors.blue));
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final getHrRequests = sl<GetHrRequests>();

    return HrPageShell(
      selectedNavIndex: 1, // 'Requests' is the 2nd item
      userName: _userName,
      child: StreamBuilder<dartz.Either<dynamic, List<LeaveRequestEntity>>>(
        stream: getHrRequests.watch(NoParams()),
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
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Inbox is empty", style: TextStyle(fontSize: 20, color: Colors.grey)),
                      Text("No pending leave requests.", style: TextStyle(color: Colors.grey)),
                    ],
                  )
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _buildRequestCard(request);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(LeaveRequestEntity request) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.userName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(request.requestType),
                  backgroundColor: request.requestType == 'Vacation' ? Colors.blue.shade100 : Colors.red.shade100,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                children: [
                  const TextSpan(text: 'Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: DateFormat.yMMMd().format(request.date)),
                ]
              )
            ),
            const SizedBox(height: 8),
             Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                children: [
                  const TextSpan(text: 'Reason: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: request.reason),
                ]
              )
            ),
            const SizedBox(height: 16),
            // Only show buttons if the request is pending
            if (request.status == 'Pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _updateStatus(request.id, 'Declined'),
                    child: const Text('Decline', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateStatus(request.id, 'Approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve'),
                  ),
                ],
              )
            else
              // Show the status if it's already been actioned
              Align(
                alignment: Alignment.centerRight,
                child: Chip(
                  label: Text(
                    request.status,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: request.status == 'Approved' ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}