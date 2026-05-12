import 'package:flutter/material.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/models/payroll_period_model.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/repositories/payroll_period_repository.dart';

class PayrollPeriodProvider extends ChangeNotifier {
  final PayrollPeriodRepository _repository = PayrollPeriodRepository();

  List<PayrollPeriodModel> _periods     = [];
  List<PayrollPeriodModel> _filtered    = [];
  bool   _isLoading    = false;
  String _message      = '';
  String _statusFilter = 'all';

  List<PayrollPeriodModel> get periods      => _filtered;
  bool   get isLoading                      => _isLoading;
  String get message                        => _message;
  String get statusFilter                   => _statusFilter;

  // Ambil periode yang sedang open (untuk digunakan di sesi lain)
  PayrollPeriodModel? get activePeriod {
    try {
      return _periods.firstWhere((p) => p.isOpen);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadPeriods() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getAll();

    if (result['success'] == true) {
      _periods = result['data'];
      _applyFilter();
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_statusFilter == 'all') {
      _filtered = List.from(_periods);
    } else {
      _filtered =
          _periods.where((p) => p.status == _statusFilter).toList();
    }
  }

  Future<Map<String, dynamic>> createPeriod(
      Map<String, dynamic> payload) async {
    final result = await _repository.create(payload);
    if (result['success'] == true) await loadPeriods();
    return result;
  }

  Future<Map<String, dynamic>> updatePeriod(
      int id, Map<String, dynamic> payload) async {
    final result = await _repository.update(id, payload);
    if (result['success'] == true) await loadPeriods();
    return result;
  }

  Future<Map<String, dynamic>> closePeriod(int id) async {
    final result = await _repository.closePeriod(id);
    if (result['success'] == true) await loadPeriods();
    return result;
  }

  Future<Map<String, dynamic>> reopenPeriod(int id) async {
    final result = await _repository.reopenPeriod(id);
    if (result['success'] == true) await loadPeriods();
    return result;
  }

  Future<Map<String, dynamic>> deletePeriod(int id) async {
    final result = await _repository.delete(id);
    if (result['success'] == true) {
      _periods.removeWhere((p) => p.id == id);
      _applyFilter();
      notifyListeners();
    }
    return result;
  }
}