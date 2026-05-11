import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../../../core/storage/local_storage.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  AuthStatus _status  = AuthStatus.initial;
  UserModel? _user;
  String     _message = '';

  AuthStatus get status  => _status;
  UserModel? get user    => _user;
  String     get message => _message;
  bool get isLoading     => _status == AuthStatus.loading;

  // Cek apakah sudah login (untuk SplashScreen)
  Future<bool> checkAuth() async {
    if (!LocalStorage.isLoggedIn()) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    // Load profil dari API untuk verifikasi token masih valid
    final result = await _repository.getProfile();
    if (result['success'] == true) {
      _user   = result['user'];
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }

    // Token tidak valid — bersihkan
    await LocalStorage.clearAll();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  // Login
  Future<bool> login(String email, String password) async {
    _status  = AuthStatus.loading;
    _message = '';
    notifyListeners();

    final result = await _repository.login(email: email, password: password);

    if (result['success'] == true) {
      _user    = result['user'];
      _status  = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }

    _message = result['message'] ?? 'Login gagal.';
    _status  = AuthStatus.error;
    notifyListeners();
    return false;
  }

  // Get Profile
  Future<void> loadProfile() async {
    final result = await _repository.getProfile();
    if (result['success'] == true) {
      _user = result['user'];
      notifyListeners();
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    final result = await _repository.updateProfile(
      name:  name,
      email: email,
      phone: phone,
    );

    if (result['success'] == true) {
      _user = result['user'];
      notifyListeners();
    }

    return result;
  }

  // Change Password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _repository.changePassword(
      currentPassword:          currentPassword,
      newPassword:              newPassword,
      newPasswordConfirmation:  confirmPassword,
    );
  }

  // Logout
  Future<void> logout() async {
    await _repository.logout();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}