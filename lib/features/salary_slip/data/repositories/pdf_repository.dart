import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobileremunerationapplication/core/constants/api_constants.dart';
import 'package:mobileremunerationapplication/core/network/api_client.dart';

class PdfRepository {
  final ApiClient _apiClient = ApiClient();

  // POST generate PDF & simpan path di server
  Future<Map<String, dynamic>> generatePdf(int slipId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.salarySlips}/$slipId/generate-pdf',
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
            e.response?.data?['message'] ?? 'Gagal generate PDF.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // Download PDF ke lokal device dan kembalikan path lokal
  Future<Map<String, dynamic>> downloadPdf(int slipId,
      String fileName) async {
    try {
      // Ambil direktori temporary
      final dir  = await getTemporaryDirectory();
      final path = '${dir.path}/$fileName';

      // Download PDF dari endpoint
      await _apiClient.dio.download(
        '${ApiConstants.salarySlips}/$slipId/download-pdf',
        path,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );

      return {'success': true, 'path': path};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal download PDF.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Bulk generate PDF untuk semua slip di satu periode
  Future<Map<String, dynamic>> bulkGeneratePdf(
      int periodId, List<int>? slipIds) async {
    try {
      final Map<String, dynamic> payload = {'period_id': periodId};
      if (slipIds != null && slipIds.isNotEmpty) {
        payload['slip_ids'] = slipIds;
      }

      final response = await _apiClient.post(
        ApiConstants.bulkGeneratePdf,
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
        'message': e.response?.data?['message'] ?? 'Gagal bulk generate PDF.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }
}