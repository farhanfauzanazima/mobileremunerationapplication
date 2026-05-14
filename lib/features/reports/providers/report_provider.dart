import 'package:flutter/material.dart';
import 'package:mobileremunerationapplication/features/reports/data/models/report_model.dart';
import 'package:mobileremunerationapplication/features/reports/data/repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

  bool   _isLoading = false;
  String _message   = '';

  // Salary Summary
  ReportSummaryModel?          _summary;
  List<ReportCategoryModel>    _byCategory  = [];
  List<ReportEmployeeModel>    _employees   = [];
  Map<String, dynamic>?        _period;

  // Statistics
  List<StatisticsTrendModel>   _salaryTrend = [];
  List<Map<String, dynamic>>   _categoryDist = [];

  // Activity Log
  List<ActivityLogModel>       _activityLogs = [];
  Map<String, dynamic>?        _pagination;
  String                       _moduleFilter = 'all';

  bool                         get isLoading     => _isLoading;
  String                       get message       => _message;
  ReportSummaryModel?          get summary       => _summary;
  List<ReportCategoryModel>    get byCategory    => _byCategory;
  List<ReportEmployeeModel>    get employees     => _employees;
  Map<String, dynamic>?        get period        => _period;
  List<StatisticsTrendModel>   get salaryTrend   => _salaryTrend;
  List<Map<String, dynamic>>   get categoryDist  => _categoryDist;
  List<ActivityLogModel>       get activityLogs  => _activityLogs;
  Map<String, dynamic>?        get pagination    => _pagination;
  String                       get moduleFilter  => _moduleFilter;

  // Load laporan per periode
  Future<void> loadSalarySummary(int periodId) async {
    _isLoading = true;
    notifyListeners();

    final result =
        await _repository.getSalarySummary(periodId);

    if (result['success'] == true) {
      final d    = result['data'];
      _period     = d['period'];
      _summary    = d['summary'];
      _byCategory = List<ReportCategoryModel>.from(
          d['by_category']);
      _employees  = List<ReportEmployeeModel>.from(
          d['employees']);
      _message    = '';
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load statistik
  Future<void> loadStatistics() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getStatistics();

    if (result['success'] == true) {
      final d     = result['data'];
      _salaryTrend = List<StatisticsTrendModel>.from(
          d['salary_trend']);
      _categoryDist = (d['category_distribution'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      _message = '';
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Export PDF
  Future<Map<String, dynamic>> exportPdf(int periodId) async {
    return await _repository.exportPdf(periodId);
  }

  // Load activity logs
  Future<void> loadActivityLogs({
    String? module,
    int     page = 1,
  }) async {
    _isLoading = true;
    if (page == 1) _activityLogs = [];
    notifyListeners();

    final result = await _repository.getActivityLogs(
      module: _moduleFilter == 'all' ? null : _moduleFilter,
      page:   page,
    );

    if (result['success'] == true) {
      _activityLogs =
          List<ActivityLogModel>.from(result['data']);
      _pagination   = result['pagination'];
      _message      = '';
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setModuleFilter(String module) {
    _moduleFilter = module;
    loadActivityLogs();
  }
}