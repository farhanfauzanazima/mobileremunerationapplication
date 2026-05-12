import 'package:dio/dio.dart';
import 'package:mobileremunerationapplication/core/constants/api_constants.dart';
import 'package:mobileremunerationapplication/core/network/api_client.dart';
import 'package:mobileremunerationapplication/features/salary_slip/data/models/salary_slip_model.dart';

class SalarySlipRepository {
  final ApiClient _apiClient = ApiClient();

  // GET semua slip gaji
  Future<Map<String, dynamic>> getAll({
    int?    periodId,
    String? status,
    int?    employeeId,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      if (periodId   != null) params['period_id']   = periodId;
      if (status     != null) params['status']       = status;
      if (employeeId != null) params['employee_id']  = employeeId;

      final response = await _apiClient.get(
        ApiConstants.salarySlips,
        queryParameters: params,
      );
      final data = response.data;

      if (data['success'] == true) {
        final List list = data['data'] ?? [];
        return {
          'success': true,
          'data': list
              .map((e) => SalarySlipModel.fromJson(e))
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

  // GET detail slip
  Future<Map<String, dynamic>> getById(int id) async {
    try {
      final response =
          await _apiClient.get('${ApiConstants.salarySlips}/$id');
      final data = response.data;

      if (data['success'] == true) {
        return {
          'success': true,
          'data': SalarySlipModel.fromJson(data['data']),
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

  // POST buat slip (single)
  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.salarySlips,
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
          : e.response?.data?['message'] ?? 'Gagal membuat slip gaji.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // PUT update slip
  Future<Map<String, dynamic>> update(
      int id, Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.salarySlips}/$id',
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
          : e.response?.data?['message'] ?? 'Gagal update slip gaji.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // DELETE slip
  Future<Map<String, dynamic>> delete(int id) async {
    try {
      final response =
          await _apiClient.delete('${ApiConstants.salarySlips}/$id');
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal menghapus slip gaji.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // POST bulk generate
  Future<Map<String, dynamic>> bulkGenerate(
      Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.bulkGenerate,
        data: payload,
      );
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'data':    data['data'],
      };
    } on DioException catch (e) {
      final errors  = e.response?.data?['errors'];
      final message = errors != null
          ? (errors as Map).values.first[0]
          : e.response?.data?['message'] ?? 'Gagal bulk generate.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }
}