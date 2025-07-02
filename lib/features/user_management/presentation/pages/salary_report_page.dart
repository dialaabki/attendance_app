import 'package:attendance_app/core/services/pdf_service.dart';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart'; 

class SalaryReportPage extends StatefulWidget {
  final UserEntity user;

  const SalaryReportPage({super.key, required this.user});

  @override
  State<SalaryReportPage> createState() => _SalaryReportPageState();
}

class _SalaryReportPageState extends State<SalaryReportPage> {
  final double socialSecurityPercentage = 0.075;
  final int workingDaysInMonth = 22;
  final int standardHoursInDay = 8;
  final double overtimeRateMultiplier = 1.25; 
  final int totalHoursWorkedThisMonth = 184; 
  final int lateDays = 2;
  final int absentDays = 1;

  late double hourlyWage;
  late double socialSecurityDeduction;
  late double lateDeduction;
  late double absenceDeduction;
  late double overtimePay;
  late double netSalary;

  // --- ADD THESE NEW STATE VARIABLES ---
  bool _isExporting = false;
  final PdfSalaryService _pdfService = PdfSalaryService();


  @override
  void initState() {
    super.initState();
    _calculateSalary();
  }

  void _calculateSalary() {
    // This method remains exactly the same
    final baseSalary = widget.user.salary;
    final standardHoursInMonth = workingDaysInMonth * standardHoursInDay;
    hourlyWage = baseSalary / standardHoursInMonth;
    final dailyWage = baseSalary / workingDaysInMonth;
    final overtimeHours = totalHoursWorkedThisMonth - standardHoursInMonth;
    if (overtimeHours > 0) {
      overtimePay = overtimeHours * hourlyWage * overtimeRateMultiplier;
    } else {
      overtimePay = 0.0;
    }
    socialSecurityDeduction = baseSalary * socialSecurityPercentage;
    lateDeduction = lateDays * hourlyWage;
    absenceDeduction = absentDays * dailyWage;
    netSalary = baseSalary + overtimePay - socialSecurityDeduction - lateDeduction - absenceDeduction;
  }

  // --- ADD THIS NEW METHOD ---
  Future<void> _exportToPdf() async {
    setState(() => _isExporting = true);
    try {
      final month = DateFormat.yMMMM().format(DateTime.now());
      final pdfData = await _pdfService.generateSalaryPdf(
        user: widget.user,
        month: month,
        baseSalary: widget.user.salary,
        overtimePay: overtimePay,
        socialSecurityDeduction: socialSecurityDeduction,
        lateDeduction: lateDeduction,
        absenceDeduction: absenceDeduction,
        netSalary: netSalary,
      );
      
      // Use the printing package for a simple share/save dialog
      await Printing.sharePdf(bytes: pdfData, filename: 'Salary-Report-$month.pdf');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: Colors.red));
    } finally {
      if(mounted) {
        setState(() => _isExporting = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDAC844);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Report'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        // --- ADD THE EXPORT BUTTON HERE ---
        actions: [
          IconButton(
            onPressed: _isExporting ? null : _exportToPdf,
            icon: _isExporting 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                  : const Icon(Icons.picture_as_pdf),
            tooltip: 'Export as PDF',
          ),
        ],
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

  // --- All your _build... helper methods remain exactly the same ---
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