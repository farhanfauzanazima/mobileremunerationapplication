import 'package:dio/dio.dart';
import 'package:mobileremunerationapplication/core/constants/api_constants.dart';
import 'package:mobileremunerationapplication/core/network/api_client.dart';
import 'package:mobileremunerationapplication/features/email/data/models/email_history_model.dart';

class EmailRepository {
  final ApiClient _apiClient = ApiClient();

  // Kirim email ke satu karyawan
  Future<Map<String, dynamic>> sendEmail(int slipId) async {
    try {
      final response = await _apiClient.post(
        '/email/send/$slipId',
      );
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'data':    data['data'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal mengirim email.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // Kirim email massal
  Future<Map<String, dynamic>> sendBulkEmail({
    required int periodId,
    List<int>? slipIds,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'period_id': periodId,
      };
      if (slipIds != null && slipIds.isNotEmpty) {
        payload['slip_ids'] = slipIds;
      }

      final response = await _apiClient.post(
        ApiConstants.emailSendBulk,
        data: payload,
      );
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'data':    data['data'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            'Gagal mengirim email massal.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // Kirim ulang email yang gagal
  Future<Map<String, dynamic>> resendEmail(int slipId) async {
    try {
      final response = await _apiClient.post(
        '/email/resend/$slipId',
      );
      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            'Gagal mengirim ulang email.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // GET riwayat pengiriman email
  Future<Map<String, dynamic>> getHistory({
    String? status,
    int?    employeeId,
    int?    periodId,
    int     page = 1,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (status     != null) params['status']      = status;
      if (employeeId != null) params['employee_id'] = employeeId;
      if (periodId   != null) params['period_id']   = periodId;

      final response = await _apiClient.get(
        ApiConstants.emailHistory,
        queryParameters: params,
      );
      final data = response.data;

      if (data['success'] == true) {
        final List list = data['data'] ?? [];
        return {
          'success':    true,
          'data':       list
              .map((e) => EmailHistoryModel.fromJson(e))
              .toList(),
          'pagination': data['pagination'],
        };
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ?? 'Gagal memuat riwayat.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // GET riwayat per slip
  Future<Map<String, dynamic>> getSlipHistory(int slipId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.emailHistory}/$slipId',
      );
      final data = response.data;

      if (data['success'] == true) {
        final List list = data['data']?['histories'] ?? [];
        return {
          'success': true,
          'data': list
              .map((e) => EmailHistoryModel.fromJson(e))
              .toList(),
        };
      }
      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ??
            'Gagal memuat riwayat slip.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }
}