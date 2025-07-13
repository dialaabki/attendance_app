// lib/features/auth/presentation/pages/verify_device_page.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class VerifyDevicePage extends StatefulWidget {
  final String userRole;
  final bool isNewDevice; // To customize the text on the page

  const VerifyDevicePage({
    Key? key,
    required this.userRole,
    this.isNewDevice = false, // Default is initial verification
  }) : super(key: key);

  @override
  State<VerifyDevicePage> createState() => _VerifyDevicePageState();
}

class _VerifyDevicePageState extends State<VerifyDevicePage> {
  Timer? timer;
  bool canResendEmail = false;

  @override
  void initState() {
    super.initState();
    // Start listening for the user to click the verification link
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkEmailVerified(),
    );

    // Allow resending email after a delay
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => canResendEmail = true);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload();
    if (user.emailVerified) {
      timer?.cancel();

      // If this was a new device verification, we need to trust it now
      if (widget.isNewDevice) {
        await _trustCurrentDevice();
      }
      
      if (mounted) _navigateToHome();
    }
  }

  Future<void> _trustCurrentDevice() async {
    final String? deviceId = await _getDeviceId();
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (deviceId != null && userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'trustedDeviceId': deviceId,
      });
      print('New device trusted successfully: $deviceId');
    }
  }

  Future<void> _resendVerificationEmail(BuildContext context) async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent!'), backgroundColor: Colors.green),
      );
      setState(() => canResendEmail = false);
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) setState(() => canResendEmail = true);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend email: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _navigateToHome() {
    String route;
    switch (widget.userRole) {
      case 'Admin': route = '/admin_home'; break;
      case 'HR': route = '/hr_home'; break;
      default: route = '/employee_home';
    }
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.isNewDevice ? 'Verify New Device' : 'Verify Your Email';
    final bodyText = widget.isNewDevice
        ? 'For your security, we need you to verify your email to trust this new device. Please click the link sent to your inbox.'
        : 'A verification link was sent to your email. Please click that link to activate your account before logging in.';

    return Scaffold(
      appBar: AppBar(title: Text(titleText)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              Text(titleText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(bodyText, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              const SizedBox(height: 30),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Waiting for verification...'),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: canResendEmail ? () => _resendVerificationEmail(context) : null,
                child: const Text('Resend Verification Email'),
              ),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _getDeviceId() async {
    // ... code for getDeviceId ...
  }
}