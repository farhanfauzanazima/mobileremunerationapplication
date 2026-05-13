import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/email/providers/email_provider.dart';
import 'package:mobileremunerationapplication/features/email/data/models/email_history_model.dart';
import 'package:mobileremunerationapplication/features/payroll_period/providers/payroll_period_provider.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/models/payroll_period_model.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/shared/widgets/loading_widget.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';
import 'package:mobileremunerationapplication/app/routes.dart';

class EmailHistoryScreen extends StatefulWidget {
  const EmailHistoryScreen({super.key});

  @override
  State<EmailHistoryScreen> createState() =>
      _EmailHistoryScreenState();
}

class _EmailHistoryScreenState extends State<EmailHistoryScreen> {
  PayrollPeriodModel? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PayrollPeriodProvider>().loadPeriods();
      if (mounted) {
        context.read<EmailProvider>().loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [

          // ── Filter Section ────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [

                // Dropdown Periode
                Consumer<PayrollPeriodProvider>(
                  builder: (context, periodProvider, _) =>
                      DropdownButtonFormField<PayrollPeriodModel>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Filter Periode',
                      prefixIcon:
                          Icon(Icons.date_range_outlined),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<PayrollPeriodModel>(
                        value: null,
                        child: Text('Semua Periode'),
                      ),
                      ...periodProvider.periods.map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            p.periodName,
                            style:
                                const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedPeriod = val);
                      context.read<EmailProvider>().loadHistory(
                            periodId: val?.id,
                          );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Filter status chips
                Consumer<EmailProvider>(
                  builder: (context, provider, _) => Row(
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        isSelected:
                            provider.statusFilter == 'all',
                        onTap: () =>
                            provider.setStatusFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Terkirim',
                        isSelected:
                            provider.statusFilter == 'sent',
                        onTap: () =>
                            provider.setStatusFilter('sent'),
                        color: AppTheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Gagal',
                        isSelected:
                            provider.statusFilter == 'failed',
                        onTap: () =>
                            provider.setStatusFilter('failed'),
                        color: AppTheme.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── List Riwayat ──────────────────────────────────
          Expanded(
            child: Consumer<EmailProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget(
                      message: 'Memuat riwayat email...');
                }

                if (provider.histories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mark_email_unread_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada riwayat pengiriman email',
                          style: TextStyle(
                              color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadHistory(
                    periodId: _selectedPeriod?.id,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.histories.length,
                    itemBuilder: (context, index) {
                      final history =
                          provider.histories[index];
                      return _EmailHistoryCard(
                        history: history,
                        onResend: () async {
                          final result =
                              await provider.resendEmail(
                                  history.slipId ?? 0);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                  result['message'] ?? ''),
                              backgroundColor:
                                  result['success'] == true
                                      ? AppTheme.secondary
                                      : AppTheme.accent,
                              behavior:
                                  SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
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

// ── Filter Chip ─────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : AppTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Email History Card ──────────────────────────────────────────

class _EmailHistoryCard extends StatelessWidget {
  final EmailHistoryModel history;
  final VoidCallback onResend;

  const _EmailHistoryCard({
    required this.history,
    required this.onResend,
  });

  Color get _statusColor {
    switch (history.status) {
      case 'sent':    return AppTheme.secondary;
      case 'failed':  return AppTheme.accent;
      default:        return AppTheme.warning;
    }
  }

  IconData get _statusIcon {
    switch (history.status) {
      case 'sent':   return Icons.check_circle_outline;
      case 'failed': return Icons.error_outline;
      default:       return Icons.schedule_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header baris ───────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      _statusColor.withOpacity(0.1),
                  child: Icon(_statusIcon,
                      color: _statusColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        history.emailTo,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    history.statusLabel,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // ── Info tambahan ──────────────────────────────
            if (history.period != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.date_range_outlined,
                      size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    history.period!,
                    style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12),
                  ),
                ],
              ),
            ],

            if (history.sentAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Dikirim: ${Formatters.dateTime(history.sentAt)}',
                    style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12),
                  ),
                ],
              ),
            ],

            if (history.sentBy != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Oleh: ${history.sentBy}',
                    style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12),
                  ),
                ],
              ),
            ],

            // ── Error message ──────────────────────────────
            if (history.isFailed &&
                history.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color:
                          AppTheme.accent.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: AppTheme.accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        history.error!,
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Tombol kirim ulang ─────────────────────────
            if (history.isFailed) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onResend,
                  icon: const Icon(Icons.refresh_outlined,
                      size: 16),
                  label: const Text('Kirim Ulang'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppTheme.secondary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}