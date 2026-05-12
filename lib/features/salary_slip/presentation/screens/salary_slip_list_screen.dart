import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/salary_slip/providers/salary_slip_provider.dart';
import 'package:mobileremunerationapplication/features/salary_slip/data/models/salary_slip_model.dart';
import 'package:mobileremunerationapplication/features/payroll_period/providers/payroll_period_provider.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/models/payroll_period_model.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/shared/widgets/loading_widget.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';
import 'package:mobileremunerationapplication/app/routes.dart';

class SalarySlipListScreen extends StatefulWidget {
  const SalarySlipListScreen({super.key});

  @override
  State<SalarySlipListScreen> createState() =>
      _SalarySlipListScreenState();
}

class _SalarySlipListScreenState extends State<SalarySlipListScreen> {
  PayrollPeriodModel? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PayrollPeriodProvider>().loadPeriods();
      // Auto-pilih periode aktif
      final activePeriod =
          context.read<PayrollPeriodProvider>().activePeriod;
      if (activePeriod != null) {
        setState(() => _selectedPeriod = activePeriod);
        context
            .read<SalarySlipProvider>()
            .loadSlips(periodId: activePeriod.id);
      } else {
        context.read<SalarySlipProvider>().loadSlips();
      }
    });
  }

  Future<void> _confirmDelete(
      BuildContext context, SalarySlipModel slip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Slip Gaji'),
        content: Text(
            'Yakin ingin menghapus slip gaji ${slip.employeeName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final result =
          await context.read<SalarySlipProvider>().deleteSlip(slip.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? ''),
          backgroundColor: result['success'] == true
              ? AppTheme.secondary
              : AppTheme.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slip Gaji'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bulk Generate
          FloatingActionButton.small(
            heroTag: 'bulk',
            onPressed: () async {
              await Navigator.pushNamed(
                  context, AppRoutes.salarySlipBulk,
                  arguments: _selectedPeriod);
              if (context.mounted) {
                context.read<SalarySlipProvider>().loadSlips(
                    periodId: _selectedPeriod?.id);
              }
            },
            backgroundColor: AppTheme.secondary,
            tooltip: 'Bulk Generate',
            child: const Icon(Icons.group_add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          // Single Create
          FloatingActionButton.extended(
            heroTag: 'single',
            onPressed: () async {
              await Navigator.pushNamed(
                  context, AppRoutes.salarySlipCreate,
                  arguments: _selectedPeriod);
              if (context.mounted) {
                context.read<SalarySlipProvider>().loadSlips(
                    periodId: _selectedPeriod?.id);
              }
            },
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Tambah',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown Periode
                Consumer<PayrollPeriodProvider>(
                  builder: (context, periodProvider, _) {
                    return DropdownButtonFormField<PayrollPeriodModel>(
                      value: _selectedPeriod,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Periode',
                        prefixIcon: Icon(Icons.date_range_outlined),
                        isDense: true,
                      ),
                      items: periodProvider.periods
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  '${p.periodName} (${p.statusLabel})',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedPeriod = val);
                        context
                            .read<SalarySlipProvider>()
                            .loadSlips(periodId: val?.id);
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Filter status chips
                Consumer<SalarySlipProvider>(
                  builder: (context, provider, _) => Row(
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        isSelected: provider.statusFilter == 'all',
                        onTap: () => provider.setStatusFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Draft',
                        isSelected: provider.statusFilter == 'draft',
                        onTap: () =>
                            provider.setStatusFilter('draft'),
                        color: AppTheme.warning,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Terkirim',
                        isSelected: provider.statusFilter == 'sent',
                        onTap: () => provider.setStatusFilter('sent'),
                        color: AppTheme.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: Consumer<SalarySlipProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget(
                      message: 'Memuat slip gaji...');
                }

                if (_selectedPeriod == null) {
                  return const Center(
                    child: Text(
                      'Pilih periode untuk melihat slip gaji',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  );
                }

                if (provider.slips.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('Belum ada slip gaji',
                            style: TextStyle(
                                color: AppTheme.textMuted)),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap tombol Tambah untuk membuat slip gaji',
                          style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadSlips(
                      periodId: _selectedPeriod?.id),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: provider.slips.length,
                    itemBuilder: (context, index) {
                      final slip = provider.slips[index];
                      return _SlipCard(
                        slip: slip,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.salarySlipDetail,
                          arguments: slip,
                        ),
                        onDelete: () =>
                            _confirmDelete(context, slip),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SlipCard extends StatelessWidget {
  final SalarySlipModel slip;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SlipCard({
    required this.slip,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        AppTheme.primary.withOpacity(0.1),
                    child: Text(
                      slip.employeeName.isNotEmpty
                          ? slip.employeeName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slip.employeeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          slip.categoryName,
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
                      color: slip.isSent
                          ? AppTheme.secondary.withOpacity(0.1)
                          : AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      slip.statusLabel,
                      style: TextStyle(
                        color: slip.isSent
                            ? AppTheme.secondary
                            : AppTheme.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Gaji',
                          style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11)),
                      Text(
                        Formatters.currency(slip.totalSalary),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${slip.totalWorkingDays} hari',
                        style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12),
                      ),
                      if (slip.lateCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${slip.lateCount}x terlambat',
                            style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (!slip.isSent) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline,
                          size: 16),
                      label: const Text('Hapus'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.accent),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}