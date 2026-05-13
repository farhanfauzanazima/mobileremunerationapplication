import 'package:flutter/material.dart';
import 'package:mobileremunerationapplication/features/email/data/models/email_history_model.dart';
import 'package:mobileremunerationapplication/features/email/data/repositories/email_repository.dart';

class EmailProvider extends ChangeNotifier {
  final EmailRepository _repository = EmailRepository();

  List<EmailHistoryModel> _histories = [];
  bool   _isLoading    = false;
  String _message      = '';
  String _statusFilter = 'all';
  Map<String, dynamic>? _pagination;

  List<EmailHistoryModel>   get histories   => _histories;
  bool                      get isLoading   => _isLoading;
  String                    get message     => _message;
  String                    get statusFilter => _statusFilter;
  Map<String, dynamic>?     get pagination  => _pagination;

  // Load riwayat email
  Future<void> loadHistory({
    String? status,
    int?    periodId,
    int     page = 1,
  }) async {
    _isLoading = true;
    if (page == 1) _histories = [];
    notifyListeners();

    final result = await _repository.getHistory(
      status:   _statusFilter == 'all' ? null : _statusFilter,
      periodId: periodId,
      page:     page,
    );

    if (result['success'] == true) {
      _histories  = List<EmailHistoryModel>.from(result['data']);
      _pagination = result['pagination'];
      _message    = '';
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    loadHistory();
  }

  // Kirim email satu slip
  Future<Map<String, dynamic>> sendEmail(int slipId) async {
    final result = await _repository.sendEmail(slipId);
    if (result['success'] == true) await loadHistory();
    return result;
  }

  // Kirim email massal
  Future<Map<String, dynamic>> sendBulkEmail({
    required int periodId,
    List<int>?   slipIds,
  }) async {
    final result = await _repository.sendBulkEmail(
      periodId: periodId,
      slipIds:  slipIds,
    );
    if (result['success'] == true) await loadHistory();
    return result;
  }

  // Kirim ulang
  Future<Map<String, dynamic>> resendEmail(int slipId) async {
    final result = await _repository.resendEmail(slipId);
    if (result['success'] == true) await loadHistory();
    return result;
  }

  // Riwayat per slip
  Future<List<EmailHistoryModel>> getSlipHistory(
      int slipId) async {
    final result = await _repository.getSlipHistory(slipId);
    if (result['success'] == true) {
      return List<EmailHistoryModel>.from(result['data']);
    }
    return [];
  }
}