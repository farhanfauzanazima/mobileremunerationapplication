class SalaryCategoryModel {
  final int id;
  final String categoryName;
  final double baseSalary;
  final double allowance;
  final double overtimeRate;
  final double latePenalty;
  final String? description;
  final bool isActive;
  final String? createdBy;
  final String? createdAt;

  SalaryCategoryModel({
    required this.id,
    required this.categoryName,
    required this.baseSalary,
    required this.allowance,
    required this.overtimeRate,
    required this.latePenalty,
    this.description,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
  });

  factory SalaryCategoryModel.fromJson(Map<String, dynamic> json) {
    return SalaryCategoryModel(
      id:           json['id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      baseSalary:   double.tryParse(json['base_salary'].toString()) ?? 0,
      allowance:    double.tryParse(json['allowance'].toString()) ?? 0,
      overtimeRate: double.tryParse(json['overtime_rate'].toString()) ?? 0,
      latePenalty:  double.tryParse(json['late_penalty'].toString()) ?? 0,
      description:  json['description'],
      isActive:     json['is_active'] ?? true,
      createdBy:    json['created_by'],
      createdAt:    json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'base_salary':   baseSalary,
      'allowance':     allowance,
      'overtime_rate': overtimeRate,
      'late_penalty':  latePenalty,
      'description':   description,
      'is_active':     isActive,
    };
  }
}