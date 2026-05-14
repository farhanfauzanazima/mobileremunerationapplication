import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobileremunerationapplication/core/constants/api_constants.dart';
import 'package:mobileremunerationapplication/core/network/api_client.dart';
import 'package:mobileremunerationapplication/features/reports/data/models/report_model.dart';

class ReportRepository {
  final ApiClient _apiClient = ApiClient();

  // GET laporan rekap gaji per periode
  Future<Map<String, dynamic>> getSalarySummary(
      int periodId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.salarySummary,
        queryParameters: {'period_id': periodId},
      );
      final data = response.data;

      if (data['success'] == true) {
        final d = data['data'];
        return {
          'success': true,
          'data': {
            'period':      d['period'],
            'summary':     ReportSummaryModel.fromJson(
                d['summary']),
            'by_category': (d['by_category'] as List? ?? [])
                .map((e) => ReportCategoryModel.fromJson(e))
                .toList(),
            'employees':   (d['employees'] as List? ?? [])
                .map((e) => ReportEmployeeModel.fromJson(e))
                .toList(),
          },
        };
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            'Gagal memuat laporan.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // GET statistik tren gaji
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _apiClient.get(
          ApiConstants.reportStatistics);
      final data = response.data;

      if (data['success'] == true) {
        final d = data['data'];
        return {
          'success': true,
          'data': {
            'salary_trend': (d['salary_trend'] as List? ?? [])
                .map((e) =>
                    StatisticsTrendModel.fromJson(e))
                .toList(),
            'category_distribution':
                d['category_distribution'] ?? [],
          },
        };
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            'Gagal memuat statistik.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // Download PDF laporan
  Future<Map<String, dynamic>> exportPdf(int periodId) async {
    try {
      final dir  = await getTemporaryDirectory();
      final path = '${dir.path}/laporan-gaji-$periodId.pdf';

      await _apiClient.dio.download(
        '${ApiConstants.salarySummary}/export-pdf',
        path,
        queryParameters: {'period_id': periodId},
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );

      return {'success': true, 'path': path};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            'Gagal export PDF.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // GET activity logs
  Future<Map<String, dynamic>> getActivityLogs({
    String? module,
    String? action,
    int     page = 1,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (module != null) params['module'] = module;
      if (action != null) params['action'] = action;

      final response = await _apiClient.get(
        ApiConstants.activityLogs,
        queryParameters: params,
      );
      final data = response.data;

      if (data['success'] == true) {
        final List list = data['data'] ?? [];
        return {
          'success':    true,
          'data':       list
              .map((e) => ActivityLogModel.fromJson(e))
              .toList(),
          'pagination': data['pagination'],
        };
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            'Gagal memuat activity log.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }
}