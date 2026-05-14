import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/reports/providers/report_provider.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/shared/widgets/loading_widget.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';
import 'package:mobileremunerationapplication/app/routes.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Gaji'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Memuat statistik...');
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadStatistics(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tren Gaji ────────────────────────
                  const Text('Tren Pengeluaran Gaji',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text(
                    '12 periode terakhir',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 10),

                  if (provider.salaryTrend.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Belum ada data tren',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    )
                  else
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.salaryTrend.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final trend = provider.salaryTrend[index];

                          // Hitung lebar bar relatif
                          final maxSalary = provider.salaryTrend
                              .map((t) => t.totalSalary)
                              .reduce((a, b) => a > b ? a : b);
                          final ratio = maxSalary > 0
                              ? trend.totalSalary / maxSalary
                              : 0.0;

                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      trend.periodName,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      Formatters.currency(trend.totalSalary),
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: ratio.toDouble(),
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppTheme.primary,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${trend.totalEmployee} karyawan · '
                                  'Rata-rata ${Formatters.currency(trend.avgSalary)}',
                                  style: const TextStyle(
                                      color: AppTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ── Distribusi per Kategori ──────────
                  if (provider.categoryDist.isNotEmpty) ...[
                    const Text('Distribusi per Kategori',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.categoryDist.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final cat = provider.categoryDist[index];
                          return ListTile(
                            title: Text(
                              cat['category_name'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${cat['total_employee'] ?? 0} karyawan · '
                              'Rata-rata ${Formatters.currency(cat['avg_salary'] ?? 0)}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.textMuted),
                            ),
                            trailing: Text(
                              Formatters.currency(cat['total_salary'] ?? 0),
                              style: const TextStyle(
                                color: AppTheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
