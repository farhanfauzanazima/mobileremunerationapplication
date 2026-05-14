import 'package:flutter/material.dart';
import 'package:mobileremunerationapplication/features/dashboard/data/models/dashboard_model.dart';
import 'package:mobileremunerationapplication/features/dashboard/data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  bool   _isLoading = false;
  String _message   = '';

  // Data Owner
  DashboardSummaryModel?          _ownerSummary;
  List<DashboardTrendModel>       _salaryTrend    = [];
  List<DashboardCategoryStatModel> _categoryStats = [];
  Map<String, dynamic>?           _activePeriod;
  Map<String, dynamic>?           _emailStats;

  // Data Head
  Map<String, dynamic>?            _headSummary;
  List<DashboardRecentSlipModel>   _recentSlips   = [];
  List<Map<String, dynamic>>       _employeeByCategory = [];

  // Data Admin
  Map<String, dynamic>?            _adminSummary;
  List<DashboardRecentSlipModel>   _myRecentSlips = [];

  bool                             get isLoading          => _isLoading;
  String                           get message            => _message;
  DashboardSummaryModel?           get ownerSummary       => _ownerSummary;
  List<DashboardTrendModel>        get salaryTrend        => _salaryTrend;
  List<DashboardCategoryStatModel> get categoryStats      => _categoryStats;
  Map<String, dynamic>?            get activePeriod       => _activePeriod;
  Map<String, dynamic>?            get emailStats         => _emailStats;
  Map<String, dynamic>?            get headSummary        => _headSummary;
  List<DashboardRecentSlipModel>   get recentSlips        => _recentSlips;
  List<Map<String, dynamic>>       get employeeByCategory => _employeeByCategory;
  Map<String, dynamic>?            get adminSummary       => _adminSummary;
  List<DashboardRecentSlipModel>   get myRecentSlips      => _myRecentSlips;

  // Load Owner Dashboard
  Future<void> loadOwnerDashboard() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getOwnerDashboard();

    if (result['success'] == true) {
      final data = result['data'];
      _activePeriod = data['active_period'];
      _ownerSummary = data['summary'] != null
          ? DashboardSummaryModel.fromJson(data['summary'])
          : null;
      _categoryStats = (data['category_stats'] as List? ?? [])
          .map((e) => DashboardCategoryStatModel.fromJson(e))
          .toList();
      _salaryTrend = (data['salary_trend'] as List? ?? [])
          .map((e) => DashboardTrendModel.fromJson(e))
          .toList();
      _emailStats = data['email_stats'];
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load Head Dashboard
  Future<void> loadHeadDashboard() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getHeadDashboard();

    if (result['success'] == true) {
      final data   = result['data'];
      _activePeriod = data['active_period'];
      _headSummary  = data['summary'];
      _recentSlips  = (data['recent_slips'] as List? ?? [])
          .map((e) => DashboardRecentSlipModel.fromJson(e))
          .toList();
      _employeeByCategory =
          (data['employee_by_category'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load Admin Dashboard
  Future<void> loadAdminDashboard() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getAdminDashboard();

    if (result['success'] == true) {
      final data    = result['data'];
      _activePeriod = data['active_period'];
      _adminSummary = data['summary'];
      _myRecentSlips = (data['recent_slips'] as List? ?? [])
          .map((e) => DashboardRecentSlipModel.fromJson(e))
          .toList();
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }
}