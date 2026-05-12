import 'package:intl/intl.dart';

class Formatters {
  // Format Rupiah: Rp 3.500.000
  static String currency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final num value = num.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // Format tanggal: 01 Mei 2026
  static String date(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '-';
  try {
    final cleanDate = dateStr.contains('T')
        ? dateStr.substring(0, 10)
        : dateStr;
    final date = DateTime.parse(cleanDate);

    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month]} '
        '${date.year}';
  } catch (_) {
    return '-';
  }
}

  // Format tanggal + jam: 01 Mei 2026, 14:30
  static String dateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // Label role
  static String roleLabel(String role) {
    switch (role) {
      case 'owner': return 'Owner';
      case 'head':  return 'Kepala Toko';
      case 'admin': return 'Admin Toko';
      default:      return role;
    }
  }

  // Label status slip
  static String slipStatus(String status) {
    return status == 'sent' ? 'Terkirim' : 'Draft';
  }

  // Label status periode
  static String periodStatus(String status) {
    return status == 'open' ? 'Aktif' : 'Ditutup';
  }
}