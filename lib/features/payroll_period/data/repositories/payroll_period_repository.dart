import 'package:dio/dio.dart';
import 'package:mobileremunerationapplication/core/constants/api_constants.dart';
import 'package:mobileremunerationapplication/core/network/api_client.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/models/payroll_period_model.dart';

class PayrollPeriodRepository {
  final ApiClient _apiClient = ApiClient();

  // GET semua periode
  Future<Map<String, dynamic>> getAll({String? status}) async {
    try {
      final Map<String, dynamic> params = {};
      if (status != null) params['status'] = status;

      final response = await _apiClient.get(
        ApiConstants.payrollPeriods,
        queryParameters: params,
      );
      final data = response.data;

      if (data['success'] == true) {
        final List list = data['data'] ?? [];
        return {
          'success': true,
          'data': list
              .map((e) => PayrollPeriodModel.fromJson(e))
              .toList(),
        };
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal memuat data.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // GET detail periode
  Future<Map<String, dynamic>> getById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.payrollPeriods}/$id',
      );
      final data = response.data;

      if (data['success'] == true) {
        return {
          'success': true,
          'data': PayrollPeriodModel.fromJson(data['data']),
        };
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal memuat detail.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // POST buat periode
  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.payrollPeriods,
        data: payload,
      );
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } on DioException catch (e) {
      final errors  = e.response?.data?['errors'];
      final message = errors != null
          ? (errors as Map).values.first[0]
          : e.response?.data?['message'] ?? 'Gagal membuat periode.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // PUT update periode
  Future<Map<String, dynamic>> update(
      int id, Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.payrollPeriods}/$id',
        data: payload,
      );
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } on DioException catch (e) {
      final errors  = e.response?.data?['errors'];
      final message = errors != null
          ? (errors as Map).values.first[0]
          : e.response?.data?['message'] ?? 'Gagal update periode.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // PUT close periode
  Future<Map<String, dynamic>> closePeriod(int id) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.payrollPeriods}/$id/close',
      );
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal menutup periode.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // PUT reopen periode
  Future<Map<String, dynamic>> reopenPeriod(int id) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.payrollPeriods}/$id/reopen',
      );
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal membuka kembali periode.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // DELETE periode
  Future<Map<String, dynamic>> delete(int id) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.payrollPeriods}/$id',
      );
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal menghapus periode.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }
}