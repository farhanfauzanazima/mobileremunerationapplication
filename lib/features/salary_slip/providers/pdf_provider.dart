import 'package:flutter/material.dart';
import 'package:mobileremunerationapplication/features/salary_slip/data/repositories/pdf_repository.dart';

enum PdfStatus { idle, loading, success, error }

class PdfProvider extends ChangeNotifier {
  final PdfRepository _repository = PdfRepository();

  PdfStatus _status  = PdfStatus.idle;
  String    _message = '';
  String?   _localPath;
  String?   _pdfUrl;

  PdfStatus get status    => _status;
  String    get message   => _message;
  String?   get localPath => _localPath;
  String?   get pdfUrl    => _pdfUrl;
  bool      get isLoading => _status == PdfStatus.loading;

  // Generate PDF di server
  Future<Map<String, dynamic>> generatePdf(int slipId) async {
    _status = PdfStatus.loading;
    notifyListeners();

    final result = await _repository.generatePdf(slipId);

    if (result['success'] == true) {
      _pdfUrl = result['data']?['pdf_url'];
      _status = PdfStatus.success;
    } else {
      _message = result['message'] ?? '';
      _status  = PdfStatus.error;
    }

    notifyListeners();
    return result;
  }

  // Download PDF ke device
  Future<Map<String, dynamic>> downloadPdf(
      int slipId, String fileName) async {
    _status = PdfStatus.loading;
    notifyListeners();

    final result = await _repository.downloadPdf(slipId, fileName);

    if (result['success'] == true) {
      _localPath = result['path'];
      _status    = PdfStatus.success;
    } else {
      _message = result['message'] ?? '';
      _status  = PdfStatus.error;
    }

    notifyListeners();
    return result;
  }

  // Bulk generate PDF
  Future<Map<String, dynamic>> bulkGeneratePdf(
      int periodId, List<int>? slipIds) async {
    _status = PdfStatus.loading;
    notifyListeners();

    final result =
        await _repository.bulkGeneratePdf(periodId, slipIds);

    _status =
        result['success'] == true ? PdfStatus.success : PdfStatus.error;
    _message = result['message'] ?? '';
    notifyListeners();

    return result;
  }

  void reset() {
    _status    = PdfStatus.idle;
    _message   = '';
    _localPath = null;
    _pdfUrl    = null;
    notifyListeners();
  }
}