class DashboardSummaryModel {
  final int totalActiveEmployees;
  final double totalSalaryThisPeriod;
  final int totalSlipsThisPeriod;
  final int sentSlipsThisPeriod;
  final int draftSlipsThisPeriod;

  DashboardSummaryModel({
    required this.totalActiveEmployees,
    required this.totalSalaryThisPeriod,
    required this.totalSlipsThisPeriod,
    required this.sentSlipsThisPeriod,
    required this.draftSlipsThisPeriod,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalActiveEmployees: json['total_active_employees'] ?? 0,
      totalSalaryThisPeriod:
          double.tryParse(json['total_salary_this_period'].toString()) ?? 0,
      totalSlipsThisPeriod: json['total_slips_this_period'] ?? 0,
      sentSlipsThisPeriod: json['sent_slips_this_period'] ?? 0,
      draftSlipsThisPeriod: json['draft_slips_this_period'] ?? 0,
    );
  }
}

class DashboardTrendModel {
  final String periodName;
  final double totalSalary;
  final int totalSlips;

  DashboardTrendModel({
    required this.periodName,
    required this.totalSalary,
    required this.totalSlips,
  });

  factory DashboardTrendModel.fromJson(Map<String, dynamic> json) {
    return DashboardTrendModel(
      periodName: json['period_name'] ?? '',
      totalSalary: double.tryParse(json['total_salary'].toString()) ?? 0,
      totalSlips: json['total_slips'] ?? 0,
    );
  }
}

class DashboardCategoryStatModel {
  final String categoryName;
  final int employeeCount;
  final double baseSalary;

  DashboardCategoryStatModel({
    required this.categoryName,
    required this.employeeCount,
    required this.baseSalary,
  });

  factory DashboardCategoryStatModel.fromJson(Map<String, dynamic> json) {
    return DashboardCategoryStatModel(
      categoryName: json['category_name'] ?? '',
      employeeCount: json['employee_count'] ?? 0,
      baseSalary: double.tryParse(json['base_salary'].toString()) ?? 0,
    );
  }
}

class DashboardRecentSlipModel {
  final int id;
  final String? employeeName;
  final String? categoryName;
  final String? periodName;
  final double totalSalary;
  final String status;
  final String? createdAt;

  DashboardRecentSlipModel({
    required this.id,
    this.employeeName,
    this.categoryName,
    this.periodName,
    required this.totalSalary,
    required this.status,
    this.createdAt,
  });

  factory DashboardRecentSlipModel.fromJson(Map<String, dynamic> json) {
    return DashboardRecentSlipModel(
      id: json['id'] ?? 0,
      employeeName: json['employee'],
      categoryName: json['category'],
      periodName: json['period'],
      totalSalary: double.tryParse(json['total_salary'].toString()) ?? 0,
      status: json['status'] ?? 'draft',
      createdAt: json['created_at'],
    );
  }

  bool get isSent => status == 'sent';
}
