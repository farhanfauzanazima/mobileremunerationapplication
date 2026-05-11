import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email':    email,
          'password': password,
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        final token = data['data']['token'];
        final user  = UserModel.fromJson(data['data']['user']);

        // Simpan token & user ke local storage
        await LocalStorage.saveToken(token);
        await LocalStorage.saveRole(user.role);
        await LocalStorage.saveUser(
          Uri.encodeFull(data['data']['user'].toString()),
        );

        return {'success': true, 'user': user, 'token': token};
      }

      return {'success': false, 'message': data['message'] ?? 'Login gagal.'};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Terjadi kesalahan jaringan.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan tidak diketahui.'};
    }
  }

  // Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      final data     = response.data;

      if (data['success'] == true) {
        final user = UserModel.fromJson(data['data']);
        return {'success': true, 'user': user};
      }

      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Gagal memuat profil.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateProfile,
        data: {
          'name':  name,
          'email': email,
          'phone': phone,
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        final user = UserModel.fromJson(data['data']);
        return {'success': true, 'user': user};
      }

      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      final errors  = e.response?.data?['errors'];
      final message = errors != null
          ? (errors as Map).values.first[0]
          : e.response?.data?['message'] ?? 'Gagal update profil.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // Change Password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.changePassword,
        data: {
          'current_password':              currentPassword,
          'new_password':                  newPassword,
          'new_password_confirmation':     newPasswordConfirmation,
        },
      );

      final data = response.data;
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Gagal ganti password.';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan.'};
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (_) {
      // Tetap lanjut logout meski API error
    } finally {
      await LocalStorage.clearAll();
    }
  }
}