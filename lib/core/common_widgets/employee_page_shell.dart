import 'package:flutter/material.dart';

class EmployeePageShell extends StatelessWidget {
  final Widget child;
  final int selectedNavIndex;
  final String userName;

  const EmployeePageShell({
    Key? key,
    required this.child,
    required this.selectedNavIndex,
    this.userName = "User",
  }) : super(key: key);

  void _onNavItemTapped(BuildContext context, int index) {
    if (index == selectedNavIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/employee_home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/employee_timesheet');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/employee_profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDAC844);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text('Hello $userName 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        leading: const Padding(padding: EdgeInsets.only(left: 15.0), child: Icon(Icons.account_circle, size: 40, color: Colors.white)),
        leadingWidth: 60,
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedNavIndex,
        onTap: (index) => _onNavItemTapped(context, index),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Clock In/Out'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'My Timesheet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}