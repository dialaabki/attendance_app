
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UnverifiedEmailPage extends StatelessWidget {
  const UnverifiedEmailPage({Key? key}) : super(key: key);

  Future<void> _resendVerificationEmail(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent! Please check your inbox.'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend email: $e'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDAC844);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Not Verified'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevents a back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'Please Verify Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'A verification link was sent to your email address when your account was created. Please click that link to activate your account before logging in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () => _resendVerificationEmail(context),
                child: const Text('Resend Verification Email'),
              ),
               const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Sign out to ensure they are fully logged out before returning to login
                  FirebaseAuth.instance.signOut(); 
                  Navigator.of(context).pop(); // Go back to the login page
                },
                child: const Text('Back to Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}