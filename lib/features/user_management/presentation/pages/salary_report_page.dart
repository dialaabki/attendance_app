import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalaryReportPage extends StatefulWidget {
  final UserEntity user;

  const SalaryReportPage({super.key, required this.user});

  @override
  State<SalaryReportPage> createState() => _SalaryReportPageState();
}

class _SalaryReportPageState extends State<SalaryReportPage> {
  // --- Constants for Calculation ---
  final double socialSecurityPercentage = 0.075;
  final int workingDaysInMonth = 22;
  final int standardHoursInDay = 8;
  final double overtimeRateMultiplier = 1.25; 
  final int totalHoursWorkedThisMonth = 184; 
  final int lateDays = 2;
  final int absentDays = 1;

  // --- State variables for calculated values ---
  late double hourlyWage;
  late double socialSecurityDeduction;
  late double lateDeduction;
  late double absenceDeduction;
  late double overtimePay;
  late double netSalary;

  @override
  void initState() {
    super.initState();
    _calculateSalary();
  }

  void _calculateSalary() {
    final baseSalary = widget.user.salary;
    final standardHoursInMonth = workingDaysInMonth * standardHoursInDay;

    // 1. Calculate base hourly and daily wage
    hourlyWage = baseSalary / standardHoursInMonth;
    final dailyWage = baseSalary / workingDaysInMonth;

    // 2. Calculate Overtime
    final overtimeHours = totalHoursWorkedThisMonth - standardHoursInMonth;
    if (overtimeHours > 0) {
      overtimePay = overtimeHours * hourlyWage * overtimeRateMultiplier;
    } else {
      overtimePay = 0.0;
    }

    // 3. Calculate Deductions
    socialSecurityDeduction = baseSalary * socialSecurityPercentage;
    lateDeduction = lateDays * hourlyWage; // Assuming 1 hour lost per late day
    absenceDeduction = absentDays * dailyWage;

    // 4. Calculate Final Net Salary
    // Net Salary = Base Salary + Overtime Pay - All Deductions
    netSalary = baseSalary + overtimePay - socialSecurityDeduction - lateDeduction - absenceDeduction;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDAC844);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Report'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildReportHeader(),
          const SizedBox(height: 24),
          _buildEarningsCard(),
          const SizedBox(height: 16),
          _buildDeductionsCard(),
          const SizedBox(height: 24),
          _buildNetSalaryCard(),
        ],
      ),
    );
  }

  Widget _buildReportHeader() {
    return Column(
      children: [
        Text(widget.user.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text("For the month of ${DateFormat.yMMMM().format(DateTime.now())}", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildEarningsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Earnings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            const Divider(),
            _buildReportRow("Base Salary", widget.user.salary, isEarning: true),
            // --- ADDED THIS ROW ---
            _buildReportRow("Overtime Pay", overtimePay, isEarning: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Deductions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const Divider(),
            _buildReportRow("Social Security (7.5%)", -socialSecurityDeduction),
            _buildReportRow("Late Deduction ($lateDays days)", -lateDeduction),
            _buildReportRow("Absence Deduction ($absentDays days)", -absenceDeduction),
          ],
        ),
      ),
    );
  }

  Widget _buildNetSalaryCard() {
    return Card(
      elevation: 4,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Net Salary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              '${netSalary.toStringAsFixed(2)} JOD',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String title, double amount, {bool isEarning = false}) {
    // Hide the row if the amount is zero (e.g., no overtime)
    if (amount == 0 && isEarning) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            amount.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 16, 
              color: amount >= 0 ? Colors.green : Colors.red, 
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}