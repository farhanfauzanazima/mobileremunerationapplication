class EmailHistoryModel {
  final int id;
  final int? slipId;
  final String? period;
  final Map<String, dynamic>? employee;
  final String emailTo;
  final String subject;
  final String status;
  final String? error;
  final String? sentAt;
  final String? sentBy;
  final String? createdAt;

  EmailHistoryModel({
    required this.id,
    this.slipId,
    this.period,
    this.employee,
    required this.emailTo,
    required this.subject,
    required this.status,
    this.error,
    this.sentAt,
    this.sentBy,
    this.createdAt,
  });

  factory EmailHistoryModel.fromJson(Map<String, dynamic> json) {
    return EmailHistoryModel(
      id:        json['id'] ?? 0,
      slipId:    json['slip_id'],
      period:    json['period'],
      employee:  json['employee'] != null
          ? Map<String, dynamic>.from(json['employee'])
          : null,
      emailTo:   json['email_to'] ?? '',
      subject:   json['subject'] ?? '',
      status:    json['status'] ?? 'pending',
      error:     json['error'],
      sentAt:    json['sent_at'],
      sentBy:    json['sent_by'],
      createdAt: json['created_at'],
    );
  }

  bool get isSent    => status == 'sent';
  bool get isFailed  => status == 'failed';
  bool get isPending => status == 'pending';

  String get statusLabel {
    switch (status) {
      case 'sent':    return 'Terkirim';
      case 'failed':  return 'Gagal';
      case 'pending': return 'Menunggu';
      default:        return status;
    }
  }

  String get employeeName =>
      employee?['full_name'] ?? '-';
  String get employeeCode =>
      employee?['employee_code'] ?? '-';
}