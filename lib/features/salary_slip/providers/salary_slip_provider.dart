import 'package:flutter/material.dart';
import 'package:mobileremunerationapplication/features/salary_slip/data/models/salary_slip_model.dart';
import 'package:mobileremunerationapplication/features/salary_slip/data/repositories/salary_slip_repository.dart';

class SalarySlipProvider extends ChangeNotifier {
  final SalarySlipRepository _repository = SalarySlipRepository();

  List<SalarySlipModel> _slips    = [];
  bool   _isLoading  = false;
  String _message    = '';
  int?   _selectedPeriodId;
  String _statusFilter = 'all';

  List<SalarySlipModel> get slips        => _slips;
  bool   get isLoading                   => _isLoading;
  String get message                     => _message;
  int?   get selectedPeriodId            => _selectedPeriodId;
  String get statusFilter                => _statusFilter;

  Future<void> loadSlips({int? periodId, String? status}) async {
    _isLoading = true;
    if (periodId != null) _selectedPeriodId = periodId;
    notifyListeners();

    final result = await _repository.getAll(
      periodId: _selectedPeriodId,
      status:   _statusFilter == 'all' ? null : _statusFilter,
    );

    if (result['success'] == true) {
      _slips   = result['data'];
      _message = '';
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    loadSlips();
  }

  void setPeriodId(int? id) {
    _selectedPeriodId = id;
    loadSlips();
  }

  Future<Map<String, dynamic>> createSlip(
      Map<String, dynamic> payload) async {
    final result = await _repository.create(payload);
    if (result['success'] == true) await loadSlips();
    return result;
  }

  Future<Map<String, dynamic>> updateSlip(
      int id, Map<String, dynamic> payload) async {
    final result = await _repository.update(id, payload);
    if (result['success'] == true) await loadSlips();
    return result;
  }

  Future<Map<String, dynamic>> deleteSlip(int id) async {
    final result = await _repository.delete(id);
    if (result['success'] == true) {
      _slips.removeWhere((s) => s.id == id);
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> bulkGenerate(
      Map<String, dynamic> payload) async {
    final result = await _repository.bulkGenerate(payload);
    if (result['success'] == true) await loadSlips();
    return result;
  }
}