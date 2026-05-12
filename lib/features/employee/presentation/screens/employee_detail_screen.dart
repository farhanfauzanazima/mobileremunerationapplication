import 'package:flutter/material.dart';
import '../../data/models/employee_model.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../app/routes.dart';

class EmployeeDetailScreen extends StatelessWidget {
  const EmployeeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employee =
        ModalRoute.of(context)!.settings.arguments as EmployeeModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Karyawan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.employeeEdit,
              arguments: employee,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          AppTheme.primary.withOpacity(0.1),
                      child: Text(
                        employee.initials,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            employee.categoryName,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: employee.isActive
                                  ? AppTheme.secondary.withOpacity(0.1)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              employee.statusLabel,
                              style: TextStyle(
                                color: employee.isActive
                                    ? AppTheme.secondary
                                    : AppTheme.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Detail Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Karyawan',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const Divider(),
                    _DetailRow(
                        icon: Icons.badge_outlined,
                        label: 'Kode Karyawan',
                        value: employee.employeeCode ?? '-'),
                    _DetailRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: employee.email),
                    _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'No. Telepon',
                        value: employee.phone),
                    _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tanggal Bergabung',
                        value: Formatters.date(employee.joinDate)),
                    _DetailRow(
                        icon: Icons.category_outlined,
                        label: 'Kategori Gaji',
                        value: employee.categoryName),
                    _DetailRow(
                        icon: Icons.person_outline,
                        label: 'Dibuat Oleh',
                        value: employee.createdBy ?? '-'),
                    _DetailRow(
                        icon: Icons.access_time,
                        label: 'Bergabung Sejak',
                        value: Formatters.date(employee.createdAt)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}