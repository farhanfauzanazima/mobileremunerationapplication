import 'package:flutter/material.dart';
import 'package:mobileremunerationapplication/features/salary_slip/data/models/salary_slip_model.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';

class SalarySlipDetailScreen extends StatelessWidget {
  const SalarySlipDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final slip =
        ModalRoute.of(context)!.settings.arguments as SalarySlipModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Slip Gaji'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              AppTheme.primary.withOpacity(0.1),
                          child: Text(
                            slip.employeeName.isNotEmpty
                                ? slip.employeeName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                slip.employeeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(slip.categoryName,
                                  style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 13)),
                              Text(slip.periodName,
                                  style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: slip.isSent
                                ? AppTheme.secondary.withOpacity(0.1)
                                : AppTheme.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            slip.statusLabel,
                            style: TextStyle(
                              color: slip.isSent
                                  ? AppTheme.secondary
                                  : AppTheme.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Kehadiran
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rekap Kehadiran',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            label: 'Hari Masuk',
                            value:
                                '${slip.totalWorkingDays} hari',
                            color: AppTheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            label: 'Terlambat',
                            value: '${slip.lateCount}x',
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            label: 'Bonus',
                            value: slip.bonus > 0 ? 'Ada' : '-',
                            color: AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Rincian Gaji
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rincian Gaji',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const Divider(),

                    // Pendapatan
                    _SalaryRow(
                      label: 'Gaji Pokok',
                      value: Formatters.currency(
                          slip.baseSalaryAmount),
                      color: AppTheme.secondary,
                    ),
                    _SalaryRow(
                      label: 'Tunjangan',
                      value: Formatters.currency(
                          slip.allowanceAmount),
                      color: AppTheme.secondary,
                    ),
                    if (slip.bonus > 0)
                      _SalaryRow(
                        label: 'Bonus',
                        value: Formatters.currency(slip.bonus),
                        color: AppTheme.secondary,
                      ),

                    const Divider(height: 20),

                    // Potongan
                    if (slip.latePenaltyAmount > 0)
                      _SalaryRow(
                        label:
                            'Potongan Terlambat (${slip.lateCount}x)',
                        value:
                            '- ${Formatters.currency(slip.latePenaltyAmount)}',
                        color: AppTheme.accent,
                      ),
                    if (slip.additionalDeduction > 0)
                      _SalaryRow(
                        label: 'Potongan Lainnya',
                        value:
                            '- ${Formatters.currency(slip.additionalDeduction)}',
                        color: AppTheme.accent,
                      ),

                    const SizedBox(height: 12),

                    // Total
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Gaji Bersih',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            Formatters.currency(slip.totalSalary),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (slip.notes != null && slip.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Catatan',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const Divider(),
                      Text(slip.notes!,
                          style: const TextStyle(
                              color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SalaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SalaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}