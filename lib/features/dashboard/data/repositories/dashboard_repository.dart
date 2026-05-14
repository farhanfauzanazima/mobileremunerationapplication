import 'package:dio/dio.dart';
import 'package:mobileremunerationapplication/core/constants/api_constants.dart';
import 'package:mobileremunerationapplication/core/network/api_client.dart';

class DashboardRepository {
  final ApiClient _apiClient = ApiClient();

  // GET dashboard owner
  Future<Map<String, dynamic>> getOwnerDashboard() async {
    try {
      final response =
          await _apiClient.get(ApiConstants.dashboardOwner);
      final data = response.data;
      if (data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            'Gagal memuat dashboard.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // GET dashboard head
  Future<Map<String, dynamic>> getHeadDashboard() async {
    try {
      final response =
          await _apiClient.get(ApiConstants.dashboardHead);
      final data = response.data;
      if (data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            'Gagal memuat dashboard.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // GET dashboard admin
  Future<Map<String, dynamic>> getAdminDashboard() async {
    try {
      final response =
          await _apiClient.get(ApiConstants.dashboardAdmin);
      final data = response.data;
      if (data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            'Gagal memuat dashboard.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }
}