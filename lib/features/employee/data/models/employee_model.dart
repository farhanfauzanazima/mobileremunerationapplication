class EmployeeModel {
  final int id;
  final String? employeeCode;
  final String fullName;
  final String email;
  final String phone;
  final String? joinDate;
  final String status;
  final Map<String, dynamic>? category;
  final String? createdBy;
  final String? createdAt;

  EmployeeModel({
    required this.id,
    this.employeeCode,
    required this.fullName,
    required this.email,
    required this.phone,
    this.joinDate,
    this.status = 'active',
    this.category,
    this.createdBy,
    this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id:           json['id'] ?? 0,
      employeeCode: json['employee_code'],
      fullName:     json['full_name'] ?? '',
      email:        json['email'] ?? '',
      phone:        json['phone'] ?? '',
      joinDate:     json['join_date'],
      status:       json['status'] ?? 'active',
      category:     json['category'] != null
          ? Map<String, dynamic>.from(json['category'])
          : null,
      createdBy:    json['created_by'],
      createdAt:    json['created_at'],
    );
  }

  bool get isActive => status == 'active';

  String get categoryName => category?['category_name'] ?? '-';
  int    get categoryId   => category?['id'] ?? 0;

  String get statusLabel => isActive ? 'Aktif' : 'Nonaktif';

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 1).toUpperCase();
  }
}