import 'dart:typed_data';
import 'package:attendance_app/features/auth/business/entities/user_entity.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfSalaryService {
  Future<Uint8List> generateSalaryPdf({
    required UserEntity user,
    required String month,
    required double baseSalary,
    required double overtimePay,
    required double socialSecurityDeduction,
    required double lateDeduction,
    required double absenceDeduction,
    required double netSalary,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(month, user.fullName),
              pw.SizedBox(height: 20),
              _buildSectionTitle("Earnings", PdfColors.green),
              _buildPdfRow("Base Salary", baseSalary, isEarning: true),
              if (overtimePay > 0)
                _buildPdfRow("Overtime Pay", overtimePay, isEarning: true),
              pw.SizedBox(height: 20),
              _buildSectionTitle("Deductions", PdfColors.red),
              _buildPdfRow("Social Security (7.5%)", -socialSecurityDeduction),
              _buildPdfRow("Late Deduction", -lateDeduction),
              _buildPdfRow("Absence Deduction", -absenceDeduction),
              pw.Divider(height: 30, thickness: 2),
              _buildNetSalaryRow("Net Salary", netSalary),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  pw.Widget _buildHeader(String month, String employeeName) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          pw.Text("Salary Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text(employeeName, style: pw.TextStyle(fontSize: 20)),
          pw.Text("For the month of $month", style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey)),
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
        pw.Divider(),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget _buildPdfRow(String title, double amount, {bool isEarning = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 14)),
          pw.Text(
            '${amount.toStringAsFixed(2)} JOD',
            style: pw.TextStyle(fontSize: 14, color: isEarning ? PdfColors.green : PdfColors.red),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildNetSalaryRow(String title, double amount) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(
            '${amount.toStringAsFixed(2)} JOD',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    final formattedDate = DateFormat.yMMMd().format(DateTime.now());
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Text(
        "Report generated on $formattedDate. This is a computer-generated document.",
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }
}