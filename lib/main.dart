import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia untuk intl
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi SharedPreferences
  await LocalStorage.init();

  // Inisialisasi Dio API Client
  ApiClient().init();

  runApp(const App());
}