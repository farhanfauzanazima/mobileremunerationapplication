import 'package:flutter/material.dart';

class ReportEmployeeModel {
  final int slipId;
  final String? employeeCode;
  final String? fullName;
  final String? email;
  final String? category;
  final int totalWorkingDays;
  final int lateCount;
  final double baseSalaryAmount;
  final double allowanceAmount;
  final double bonus;
  final double latePenaltyAmount;
  final double additionalDeduction;
  final double totalSalary;
  final String status;

  ReportEmployeeModel({
    required this.slipId,
    this.employeeCode,
    this.fullName,
    this.email,
    this.category,
    required this.totalWorkingDays,
    required this.lateCount,
    required this.baseSalaryAmount,
    required this.allowanceAmount,
    required this.bonus,
    required this.latePenaltyAmount,
    required this.additionalDeduction,
    required this.totalSalary,
    required this.status,
  });

  factory ReportEmployeeModel.fromJson(Map<String, dynamic> json) {
    return ReportEmployeeModel(
      slipId:              json['slip_id'] ?? 0,
      employeeCode:        json['employee_code'],
      fullName:            json['full_name'],
      email:               json['email'],
      category:            json['category'],
      totalWorkingDays:    json['total_working_days'] ?? 0,
      lateCount:           json['late_count'] ?? 0,
      baseSalaryAmount:    double.tryParse(
              json['base_salary_amount'].toString()) ?? 0,
      allowanceAmount:     double.tryParse(
              json['allowance_amount'].toString()) ?? 0,
      bonus:               double.tryParse(
              json['bonus'].toString()) ?? 0,
      latePenaltyAmount:   double.tryParse(
              json['late_penalty_amount'].toString()) ?? 0,
      additionalDeduction: double.tryParse(
              json['additional_deduction'].toString()) ?? 0,
      totalSalary:         double.tryParse(
              json['total_salary'].toString()) ?? 0,
      status:              json['status'] ?? 'draft',
    );
  }

  bool get isSent => status == 'sent';
}

class ReportSummaryModel {
  final int totalEmployees;
  final double totalSalary;
  final double totalBaseSalary;
  final double totalAllowance;
  final double totalBonus;
  final double totalLatePenalty;
  final double totalDeduction;
  final int totalSent;
  final int totalDraft;

  ReportSummaryModel({
    required this.totalEmployees,
    required this.totalSalary,
    required this.totalBaseSalary,
    required this.totalAllowance,
    required this.totalBonus,
    required this.totalLatePenalty,
    required this.totalDeduction,
    required this.totalSent,
    required this.totalDraft,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      totalEmployees:   json['total_employees'] ?? 0,
      totalSalary:      double.tryParse(
              json['total_salary'].toString()) ?? 0,
      totalBaseSalary:  double.tryParse(
              json['total_base_salary'].toString()) ?? 0,
      totalAllowance:   double.tryParse(
              json['total_allowance'].toString()) ?? 0,
      totalBonus:       double.tryParse(
              json['total_bonus'].toString()) ?? 0,
      totalLatePenalty: double.tryParse(
              json['total_late_penalty'].toString()) ?? 0,
      totalDeduction:   double.tryParse(
              json['total_deduction'].toString()) ?? 0,
      totalSent:        json['total_sent'] ?? 0,
      totalDraft:       json['total_draft'] ?? 0,
    );
  }
}

class ReportCategoryModel {
  final String? categoryName;
  final int totalEmployee;
  final double totalSalary;

  ReportCategoryModel({
    this.categoryName,
    required this.totalEmployee,
    required this.totalSalary,
  });

  factory ReportCategoryModel.fromJson(Map<String, dynamic> json) {
    return ReportCategoryModel(
      categoryName:  json['category_name'],
      totalEmployee: json['total_employee'] ?? 0,
      totalSalary:   double.tryParse(
              json['total_salary'].toString()) ?? 0,
    );
  }
}

class StatisticsTrendModel {
  final String periodName;
  final double totalSalary;
  final int totalEmployee;
  final double avgSalary;

  StatisticsTrendModel({
    required this.periodName,
    required this.totalSalary,
    required this.totalEmployee,
    required this.avgSalary,
  });

  factory StatisticsTrendModel.fromJson(
      Map<String, dynamic> json) {
    return StatisticsTrendModel(
      periodName:    json['period_name'] ?? '',
      totalSalary:   double.tryParse(
              json['total_salary'].toString()) ?? 0,
      totalEmployee: json['total_employee'] ?? 0,
      avgSalary:     double.tryParse(
              json['avg_salary'].toString()) ?? 0,
    );
  }
}

class ActivityLogModel {
  final int id;
  final Map<String, dynamic>? user;
  final String action;
  final String module;
  final String description;
  final String? ipAddress;
  final String? createdAt;

  ActivityLogModel({
    required this.id,
    this.user,
    required this.action,
    required this.module,
    required this.description,
    this.ipAddress,
    this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id:          json['id'] ?? 0,
      user:        json['user'] != null
          ? Map<String, dynamic>.from(json['user'])
          : null,
      action:      json['action'] ?? '',
      module:      json['module'] ?? '',
      description: json['description'] ?? '',
      ipAddress:   json['ip_address'],
      createdAt:   json['created_at'],
    );
  }

  String get userName  => user?['name'] ?? '-';
  String get userRole  => user?['role'] ?? '-';

  String get actionLabel {
    switch (action) {
      case 'login':           return 'Login';
      case 'logout':          return 'Logout';
      case 'create':          return 'Tambah';
      case 'update':          return 'Update';
      case 'delete':          return 'Hapus';
      case 'change_password': return 'Ganti Password';
      default:                return action;
    }
  }

  Color get actionColor {
    switch (action) {
      case 'login':   return const Color(0xFF27AE60);
      case 'logout':  return const Color(0xFF7F8C8D);
      case 'create':  return const Color(0xFF2980B9);
      case 'update':  return const Color(0xFFF39C12);
      case 'delete':  return const Color(0xFFE74C3C);
      default:        return const Color(0xFF2C3E50);
    }
  }
}