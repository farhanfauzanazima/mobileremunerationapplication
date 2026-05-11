import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SharedPreferences
  await LocalStorage.init();

  // Inisialisasi Dio API Client
  ApiClient().init();

  runApp(const App());
}