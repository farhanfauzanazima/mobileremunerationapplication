class PayrollPeriodModel {
  final int id;
  final String periodName;
  final String startDate;
  final String endDate;
  final String status;
  final String? notes;
  final String? createdBy;
  final String? createdAt;

  PayrollPeriodModel({
    required this.id,
    required this.periodName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  factory PayrollPeriodModel.fromJson(Map<String, dynamic> json) {
    return PayrollPeriodModel(
      id:         json['id'] ?? 0,
      periodName: json['period_name'] ?? '',
      startDate:  json['start_date'] ?? '',
      endDate:    json['end_date'] ?? '',
      status:     json['status'] ?? 'open',
      notes:      json['notes'],
      createdBy:  json['created_by'],
      createdAt:  json['created_at'],
    );
  }

  bool get isOpen   => status == 'open';
  bool get isClosed => status == 'closed';

  String get statusLabel => isOpen ? 'Aktif' : 'Ditutup';
}