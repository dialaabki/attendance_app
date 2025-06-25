import 'package:flutter/material.dart';

class AdminPageShell extends StatefulWidget {
  final String title;
  final Widget child;
  final int? selectedNavIndex;
  final FloatingActionButton? floatingActionButton;
  final bool showBackButton;

  const AdminPageShell({
    Key? key,
    required this.title,
    required this.child,
    this.selectedNavIndex,
    this.floatingActionButton,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  _AdminPageShellState createState() => _AdminPageShellState();
}

class _AdminPageShellState extends State<AdminPageShell> {
  void _onNavItemTapped(int index) {
    if (index == widget.selectedNavIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/employees');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/admin_home');
        break;
      case 2:
        Navigator.pushNamed(context, '/add_employee');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/admin_profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDAC844);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: widget.child,
      ),
      bottomNavigationBar: widget.selectedNavIndex != null
          ? BottomNavigationBar(
              currentIndex: widget.selectedNavIndex!,
              onTap: _onNavItemTapped,
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Employees'),
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Add User'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            )
          : null,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}