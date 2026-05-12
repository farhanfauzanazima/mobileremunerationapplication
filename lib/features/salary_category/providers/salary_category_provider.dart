import 'package:flutter/material.dart';
import '../data/models/salary_category_model.dart';
import '../data/repositories/salary_category_repository.dart';

class SalaryCategoryProvider extends ChangeNotifier {
  final SalaryCategoryRepository _repository = SalaryCategoryRepository();

  List<SalaryCategoryModel> _categories = [];
  bool   _isLoading = false;
  String _message   = '';

  List<SalaryCategoryModel> get categories => _categories;
  bool   get isLoading => _isLoading;
  String get message   => _message;

  // Load semua kategori
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getAll();

    if (result['success'] == true) {
      _categories = result['data'];
    } else {
      _message = result['message'] ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Tambah kategori
  Future<Map<String, dynamic>> createCategory(
      Map<String, dynamic> payload) async {
    final result = await _repository.create(payload);
    if (result['success'] == true) {
      await loadCategories();
    }
    return result;
  }

  // Update kategori
  Future<Map<String, dynamic>> updateCategory(
      int id, Map<String, dynamic> payload) async {
    final result = await _repository.update(id, payload);
    if (result['success'] == true) {
      await loadCategories();
    }
    return result;
  }

  // Hapus kategori
  Future<Map<String, dynamic>> deleteCategory(int id) async {
    final result = await _repository.delete(id);
    if (result['success'] == true) {
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    }
    return result;
  }
}