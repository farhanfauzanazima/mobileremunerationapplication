class SalarySlipModel {
  final int id;
  final Map<String, dynamic>? period;
  final Map<String, dynamic>? employee;
  final Map<String, dynamic>? category;
  final int totalWorkingDays;
  final int lateCount;
  final double bonus;
  final double additionalDeduction;
  final String? notes;
  final double baseSalaryAmount;
  final double allowanceAmount;
  final double latePenaltyAmount;
  final double totalSalary;
  final String status;
  final String? pdfPath;
  final String? pdfUrl;
  final String? sentAt;
  final String? createdAt;
  final String? createdBy;

  SalarySlipModel({
    required this.id,
    this.period,
    this.employee,
    this.category,
    required this.totalWorkingDays,
    required this.lateCount,
    required this.bonus,
    required this.additionalDeduction,
    this.notes,
    required this.baseSalaryAmount,
    required this.allowanceAmount,
    required this.latePenaltyAmount,
    required this.totalSalary,
    required this.status,
    this.pdfPath,
    this.pdfUrl,
    this.sentAt,
    this.createdAt,
    this.createdBy,
  });

  factory SalarySlipModel.fromJson(Map<String, dynamic> json) {
    return SalarySlipModel(
      id:                   json['id'] ?? 0,
      period:               json['period'] != null
          ? Map<String, dynamic>.from(json['period'])
          : null,
      employee:             json['employee'] != null
          ? Map<String, dynamic>.from(json['employee'])
          : null,
      category:             json['category'] != null
          ? Map<String, dynamic>.from(json['category'])
          : null,
      totalWorkingDays:     json['total_working_days'] ?? 0,
      lateCount:            json['late_count'] ?? 0,
      bonus:                double.tryParse(
              json['bonus'].toString()) ?? 0,
      additionalDeduction:  double.tryParse(
              json['additional_deduction'].toString()) ?? 0,
      notes:                json['notes'],
      baseSalaryAmount:     double.tryParse(
              json['base_salary_amount'].toString()) ?? 0,
      allowanceAmount:      double.tryParse(
              json['allowance_amount'].toString()) ?? 0,
      latePenaltyAmount:    double.tryParse(
              json['late_penalty_amount'].toString()) ?? 0,
      totalSalary:          double.tryParse(
              json['total_salary'].toString()) ?? 0,
      status:               json['status'] ?? 'draft',
      pdfPath:              json['pdf_path'],
      pdfUrl:               json['pdf_url'],
      sentAt:               json['sent_at'],
      createdAt:            json['created_at'],
      createdBy:            json['created_by'],
    );
  }

  bool get isSent  => status == 'sent';
  bool get isDraft => status == 'draft';

  String get statusLabel  => isSent ? 'Terkirim' : 'Draft';
  String get employeeName => employee?['full_name'] ?? '-';
  String get employeeCode => employee?['employee_code'] ?? '-';
  String get periodName   => period?['period_name'] ?? '-';
  String get categoryName => category?['category_name'] ?? '-';
}