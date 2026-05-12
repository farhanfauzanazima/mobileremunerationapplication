import 'package:flutter/material.dart';
import '../data/models/employee_model.dart';
import '../data/repositories/employee_repository.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeRepository _repository = EmployeeRepository();

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filtered  = [];
  bool   _isLoading  = false;
  String _message    = '';
  String _searchQuery = '';
  String _statusFilter = 'all';

  List<EmployeeModel> get employees    => _filtered;
  bool   get isLoading                 => _isLoading;
  String get message                   => _message;
  String get statusFilter              => _statusFilter;

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getAll();

    if (result['success'] == true) {
      _employees = result['data'];
      _applyFilter();
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filtered = _employees.where((e) {
      final matchStatus = _statusFilter == 'all' || e.status == _statusFilter;
      final matchSearch = _searchQuery.isEmpty ||
          e.fullName.toLowerCase().contains(_searchQuery) ||
          e.email.toLowerCase().contains(_searchQuery) ||
          (e.employeeCode?.toLowerCase().contains(_searchQuery) ?? false);
      return matchStatus && matchSearch;
    }).toList();
  }

  Future<Map<String, dynamic>> createEmployee(
      Map<String, dynamic> payload) async {
    final result = await _repository.create(payload);
    if (result['success'] == true) await loadEmployees();
    return result;
  }

  Future<Map<String, dynamic>> updateEmployee(
      int id, Map<String, dynamic> payload) async {
    final result = await _repository.update(id, payload);
    if (result['success'] == true) await loadEmployees();
    return result;
  }

  Future<Map<String, dynamic>> deleteEmployee(int id) async {
    final result = await _repository.delete(id);
    if (result['success'] == true) {
      _employees.removeWhere((e) => e.id == id);
      _applyFilter();
      notifyListeners();
    }
    return result;
  }
}