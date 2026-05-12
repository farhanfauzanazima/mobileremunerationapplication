import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/salary_category_model.dart';

class SalaryCategoryRepository {
  final ApiClient _apiClient = ApiClient();

  // GET semua kategori
  Future<Map<String, dynamic>> getAll() async {
    try {
      final response = await _apiClient.get(ApiConstants.salaryCategories);
      final data     = response.data;

      if (data['success'] == true) {
        final List list = data['data'] ?? [];
        final categories = list
            .map((e) => SalaryCategoryModel.fromJson(e))
            .toList();
        return {'success': true, 'data': categories};
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

  // GET detail kategori
  Future<Map<String, dynamic>> getById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.salaryCategories}/$id',
      );
      final data = response.data;

      if (data['success'] == true) {
        return {
          'success': true,
          'data': SalaryCategoryModel.fromJson(data['data']),
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

  // POST buat kategori baru
  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.salaryCategories,
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
          : e.response?.data?['message'] ?? 'Gagal membuat kategori.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // PUT update kategori
  Future<Map<String, dynamic>> update(
      int id, Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.salaryCategories}/$id',
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
          : e.response?.data?['message'] ?? 'Gagal update kategori.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // DELETE kategori
  Future<Map<String, dynamic>> delete(int id) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.salaryCategories}/$id',
      );
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal menghapus kategori.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }
}