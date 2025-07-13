import 'package:attendance_app/features/auth/business/usecases/login_user.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'verify_device_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final loginUseCase = sl<LoginUser>();
    final result = await loginUseCase(
      LoginParams(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );

    if (!mounted) {
      setState(() => _isLoading = false);
      return;
    }

    await result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Login failed: ${failure.message}'),
              backgroundColor: Colors.red),
        );
      },
      (userEntity) async {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not find user session.')));
          return;
        }

        // --- DEVICE ID VERIFICATION LOGIC ---
        // Must reload to get the latest email verification status from Firebase
        await firebaseUser.reload();
        final bool isEmailVerified = firebaseUser.emailVerified;

        if (!isEmailVerified) {
          // **Case 1: First-ever login.** User must verify their email.
          print('Login blocked: Email not verified.');
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VerifyDevicePage(userRole: userEntity.role),
          ));
          return;
        }

        // Email is verified, now check the device
        final String? currentDeviceId = await _getDeviceId();
        final String? trustedDeviceId = userEntity.trustedDeviceId;

        if (trustedDeviceId == null) {
          // **Case 2: First login on ANY device after email verification.**
          // We trust this device immediately and save its ID.
          print('First login on a device. Trusting this device and logging in.');
          if (currentDeviceId != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userEntity.uid)
                .update({
              'trustedDeviceId': currentDeviceId,
            });
          }
          _navigateToHome(userEntity.role);
        } else if (currentDeviceId != trustedDeviceId) {
          // **Case 3: User is on a new, untrusted device.**
          // Force them to re-verify their email to trust this new device.
          print('Login blocked: Untrusted device. Forcing re-verification.');
          // NOTE: We can't set emailVerified to false, so we just send a new link
          // and treat the flow as if they need to verify again.
          await firebaseUser.sendEmailVerification();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VerifyDevicePage(
              userRole: userEntity.role,
              isNewDevice: true, // Tell the page to show specific text
            ),
          ));
        } else {
          // **Case 4: User is on their known, trusted device.**
          print('Trusted device login successful.');
          _navigateToHome(userEntity.role);
        }
      },
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToHome(String role) {
    String route;
    switch (role) {
      case 'Admin':
        route = '/admin_home';
        break;
      case 'HR':
        route = '/hr_home';
        break;
      default:
        route = '/employee_home';
    }
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    }
  }

  // Helper function to get the unique device ID
  Future<String?> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      }
    } catch (e) {
      print('Failed to get device ID: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDAC844);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                child:
                    Image.asset('assets/images/falcons_logo.png', height: 500),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25.0, vertical: 30.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Log in',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Serif',
                              color: primaryColor)),
                      const SizedBox(height: 30),
                      const Text('Username',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                        validator: (value) => (value?.isEmpty ?? true)
                            ? 'Please enter your email'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const Text('Password',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                        validator: (value) => (value?.isEmpty ?? true)
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            elevation: 5,
                          ),
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Log in',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}