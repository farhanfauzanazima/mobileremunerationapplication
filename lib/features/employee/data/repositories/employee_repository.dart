import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/employee_model.dart';

class EmployeeRepository {
  final ApiClient _apiClient = ApiClient();

  // GET semua karyawan
  Future<Map<String, dynamic>> getAll({
    String? status,
    String? search,
    int? categoryId,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      if (status != null)     params['status']      = status;
      if (search != null)     params['search']      = search;
      if (categoryId != null) params['category_id'] = categoryId;

      final response = await _apiClient.get(
        ApiConstants.employees,
        queryParameters: params,
      );
      final data = response.data;

      if (data['success'] == true) {
        final List list = data['data'] ?? [];
        return {
          'success': true,
          'data': list.map((e) => EmployeeModel.fromJson(e)).toList(),
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

  // GET detail karyawan
  Future<Map<String, dynamic>> getById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.employees}/$id');
      final data     = response.data;

      if (data['success'] == true) {
        return {
          'success': true,
          'data': EmployeeModel.fromJson(data['data']),
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

  // POST buat karyawan
  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.employees,
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
          : e.response?.data?['message'] ?? 'Gagal menambah karyawan.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // PUT update karyawan
  Future<Map<String, dynamic>> update(
      int id, Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.employees}/$id',
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
          : e.response?.data?['message'] ?? 'Gagal update karyawan.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // DELETE karyawan
  Future<Map<String, dynamic>> delete(int id) async {
    try {
      final response =
          await _apiClient.delete('${ApiConstants.employees}/$id');
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal menghapus karyawan.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }
}