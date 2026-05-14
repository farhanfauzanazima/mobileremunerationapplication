import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/reports/providers/report_provider.dart';
import 'package:mobileremunerationapplication/features/payroll_period/providers/payroll_period_provider.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/models/payroll_period_model.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/shared/widgets/loading_widget.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';
import 'package:mobileremunerationapplication/app/routes.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  PayrollPeriodModel? _selectedPeriod;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PayrollPeriodProvider>().loadPeriods();
      // Auto-pilih periode pertama
      final periods =
          context.read<PayrollPeriodProvider>().periods;
      if (periods.isNotEmpty) {
        setState(() => _selectedPeriod = periods.first);
        context
            .read<ReportProvider>()
            .loadSalarySummary(periods.first.id);
      }
    });
  }

  Future<void> _exportPdf() async {
    if (_selectedPeriod == null) return;

    setState(() => _isExporting = true);

    final result = await context
        .read<ReportProvider>()
        .exportPdf(_selectedPeriod!.id);

    if (!mounted) return;
    setState(() => _isExporting = false);

    if (result['success'] == true) {
      Navigator.pushNamed(
        context,
        AppRoutes.pdfViewer,
        arguments: {
          'path':  result['path'],
          'title': 'Laporan ${_selectedPeriod!.periodName}',
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal export'),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penggajian'),
        actions: [
          // Tombol Export PDF
          _isExporting
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                      Icons.picture_as_pdf_outlined),
                  onPressed: _selectedPeriod != null
                      ? _exportPdf
                      : null,
                  tooltip: 'Export PDF',
                ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          // Pilih Periode
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Consumer<PayrollPeriodProvider>(
              builder: (context, periodProvider, _) =>
                  DropdownButtonFormField<PayrollPeriodModel>(
                value: _selectedPeriod,
                decoration: const InputDecoration(
                  labelText: 'Pilih Periode',
                  prefixIcon:
                      Icon(Icons.date_range_outlined),
                  isDense: true,
                ),
                items: periodProvider.periods
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.periodName} (${p.statusLabel})',
                            style: const TextStyle(
                                fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedPeriod = val);
                  if (val != null) {
                    context
                        .read<ReportProvider>()
                        .loadSalarySummary(val.id);
                  }
                },
              ),
            ),
          ),

          // Konten Laporan
          Expanded(
            child: Consumer<ReportProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget(
                      message: 'Memuat laporan...');
                }

                if (_selectedPeriod == null ||
                    provider.summary == null) {
                  return const Center(
                    child: Text(
                      'Pilih periode untuk melihat laporan',
                      style: TextStyle(
                          color: AppTheme.textMuted),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      provider.loadSalarySummary(
                          _selectedPeriod!.id),
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        // ── Info Periode ────────────────
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primary,
                                Color(0xFF3D5A73)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                  Icons.summarize_outlined,
                                  color: Colors.white,
                                  size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      provider.period?[
                                              'period_name'] ??
                                          '-',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${Formatters.date(provider.period?['start_date'])} — '
                                      '${Formatters.date(provider.period?['end_date'])}',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Summary ─────────────────────
                        const Text('Ringkasan',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),

                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          childAspectRatio: 1.5,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          children: [
                            _SummaryTile(
                              label: 'Total Karyawan',
                              value:
                                  '${provider.summary!.totalEmployees}',
                              icon: Icons.people_outline,
                              color: AppTheme.primary,
                            ),
                            _SummaryTile(
                              label: 'Total Gaji Bersih',
                              value: Formatters.currency(
                                  provider
                                      .summary!.totalSalary),
                              icon: Icons.payments_outlined,
                              color: AppTheme.secondary,
                            ),
                            _SummaryTile(
                              label: 'Slip Terkirim',
                              value:
                                  '${provider.summary!.totalSent}',
                              icon: Icons
                                  .mark_email_read_outlined,
                              color: AppTheme.secondary,
                            ),
                            _SummaryTile(
                              label: 'Slip Draft',
                              value:
                                  '${provider.summary!.totalDraft}',
                              icon: Icons.drafts_outlined,
                              color: AppTheme.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Detail Komponen ─────────────
                        const Text('Detail Komponen',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _ComponentRow(
                                  label: 'Total Gaji Pokok',
                                  value: Formatters.currency(
                                      provider.summary!
                                          .totalBaseSalary),
                                  color: AppTheme.secondary,
                                ),
                                _ComponentRow(
                                  label: 'Total Tunjangan',
                                  value: Formatters.currency(
                                      provider.summary!
                                          .totalAllowance),
                                  color: AppTheme.secondary,
                                ),
                                _ComponentRow(
                                  label: 'Total Bonus',
                                  value: Formatters.currency(
                                      provider
                                          .summary!.totalBonus),
                                  color: AppTheme.secondary,
                                ),
                                const Divider(),
                                _ComponentRow(
                                  label:
                                      'Total Potongan Terlambat',
                                  value:
                                      '- ${Formatters.currency(provider.summary!.totalLatePenalty)}',
                                  color: AppTheme.accent,
                                ),
                                _ComponentRow(
                                  label: 'Total Potongan Lain',
                                  value:
                                      '- ${Formatters.currency(provider.summary!.totalDeduction)}',
                                  color: AppTheme.accent,
                                ),
                                const Divider(),
                                _ComponentRow(
                                  label: 'Total Bersih',
                                  value: Formatters.currency(
                                      provider
                                          .summary!.totalSalary),
                                  color: AppTheme.primary,
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Per Kategori ────────────────
                        if (provider.byCategory
                            .isNotEmpty) ...[
                          const Text('Per Kategori',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w600)),
                          const SizedBox(height: 10),
                          Card(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount:
                                  provider.byCategory.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final cat =
                                    provider.byCategory[index];
                                return ListTile(
                                  title: Text(
                                    cat.categoryName ?? '-',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    '${cat.totalEmployee} karyawan',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            AppTheme.textMuted),
                                  ),
                                  trailing: Text(
                                    Formatters.currency(
                                        cat.totalSalary),
                                    style: const TextStyle(
                                      color:
                                          AppTheme.secondary,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Per Karyawan ────────────────
                        if (provider.employees
                            .isNotEmpty) ...[
                          const Text('Detail per Karyawan',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w600)),
                          const SizedBox(height: 10),
                          Card(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount:
                                  provider.employees.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final emp =
                                    provider.employees[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppTheme
                                        .primary
                                        .withOpacity(0.1),
                                    child: Text(
                                      (emp.fullName ?? '?')
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    emp.fullName ?? '-',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w500),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        emp.category ?? '-',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme
                                                .textMuted),
                                      ),
                                      Text(
                                        '${emp.totalWorkingDays} hari'
                                        '${emp.lateCount > 0 ? ' · ${emp.lateCount}x terlambat' : ''}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme
                                                .textMuted),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        Formatters.currency(
                                            emp.totalSalary),
                                        style: const TextStyle(
                                          color:
                                              AppTheme.primary,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal: 6,
                                                vertical: 2),
                                        decoration:
                                            BoxDecoration(
                                          color: emp.isSent
                                              ? AppTheme
                                                  .secondary
                                                  .withOpacity(
                                                      0.1)
                                              : AppTheme
                                                  .warning
                                                  .withOpacity(
                                                      0.1),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(6),
                                        ),
                                        child: Text(
                                          emp.isSent
                                              ? 'Terkirim'
                                              : 'Draft',
                                          style: TextStyle(
                                            color: emp.isSent
                                                ? AppTheme
                                                    .secondary
                                                : AppTheme
                                                    .warning,
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
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
          ),
        ],
      ),
    );
  }
}

// ── Widget Helpers ──────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ComponentRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _ComponentRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
                fontWeight: isBold
                    ? FontWeight.w600
                    : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: isBold
                    ? FontWeight.bold
                    : FontWeight.w600,
              )),
        ],
      ),
    );
  }
}