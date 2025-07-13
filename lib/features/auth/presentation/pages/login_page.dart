import 'package:attendance_app/features/auth/business/usecases/login_user.dart';
import 'package:attendance_app/service_locator.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'unverified_email_page.dart'; 

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
            backgroundColor: Colors.red,
          ),
        );
      },
      (user) {
        final firebaseUser = FirebaseAuth.instance.currentUser;

        // Check if the user's email is verified
        if (firebaseUser != null && !firebaseUser.emailVerified) {
          // If NOT verified, show the dedicated page and stop the login
          print('Login blocked: Email not verified.');
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const UnverifiedEmailPage(),
          ));
          return; // Stop the login process
        }
        
        // If email IS verified, proceed to the correct home page
        print('Email is verified. Logging in.');
        if (user.role == 'Admin') {
          Navigator.pushReplacementNamed(context, '/admin_home');
        } else if (user.role == 'HR') {
          Navigator.pushReplacementNamed(context, '/hr_home');
        } else {
          Navigator.pushReplacementNamed(context, '/employee_home');
        }
      },
    );

    // This will now correctly handle the loading state
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // ------------------------------------------

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
                child: Image.asset('assets/images/falcons_logo.png', height: 500),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
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