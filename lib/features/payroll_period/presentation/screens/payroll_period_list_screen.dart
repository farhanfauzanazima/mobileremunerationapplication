import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/payroll_period/providers/payroll_period_provider.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/models/payroll_period_model.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/shared/widgets/loading_widget.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';
import 'package:mobileremunerationapplication/app/routes.dart';

class PayrollPeriodListScreen extends StatefulWidget {
  const PayrollPeriodListScreen({super.key});

  @override
  State<PayrollPeriodListScreen> createState() =>
      _PayrollPeriodListScreenState();
}

class _PayrollPeriodListScreenState
    extends State<PayrollPeriodListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayrollPeriodProvider>().loadPeriods();
    });
  }

  Future<void> _confirmDelete(
      BuildContext context, PayrollPeriodModel period) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Periode'),
        content: Text('Yakin ingin menghapus "${period.periodName}"?'),
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
      final result = await context
          .read<PayrollPeriodProvider>()
          .deletePeriod(period.id);
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

  Future<void> _toggleStatus(
      BuildContext context, PayrollPeriodModel period) async {
    final action = period.isOpen ? 'Tutup' : 'Buka Kembali';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action Periode'),
        content: Text(
            'Yakin ingin ${action.toLowerCase()} periode "${period.periodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final provider = context.read<PayrollPeriodProvider>();
      final result   = period.isOpen
          ? await provider.closePeriod(period.id)
          : await provider.reopenPeriod(period.id);

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
        title: const Text('Periode Penggajian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(
              context, AppRoutes.payrollPeriodCreate);
          if (context.mounted) {
            context.read<PayrollPeriodProvider>().loadPeriods();
          }
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Consumer<PayrollPeriodProvider>(
              builder: (context, provider, _) => Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: provider.statusFilter == 'all',
                    onTap: () => provider.setStatusFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Aktif',
                    isSelected: provider.statusFilter == 'open',
                    onTap: () => provider.setStatusFilter('open'),
                    color: AppTheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Ditutup',
                    isSelected: provider.statusFilter == 'closed',
                    onTap: () => provider.setStatusFilter('closed'),
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: Consumer<PayrollPeriodProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget(
                      message: 'Memuat periode penggajian...');
                }

                if (provider.periods.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.date_range_outlined,
                            size: 64,
                            color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('Belum ada periode penggajian',
                            style:
                                TextStyle(color: AppTheme.textMuted)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadPeriods(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.periods.length,
                    itemBuilder: (context, index) {
                      final period = provider.periods[index];
                      return _PeriodCard(
                        period: period,
                        onEdit: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.payrollPeriodCreate,
                            arguments: period,
                          );
                          if (context.mounted) provider.loadPeriods();
                        },
                        onDelete: () =>
                            _confirmDelete(context, period),
                        onToggleStatus: () =>
                            _toggleStatus(context, period),
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
            color: isSelected ? color : Colors.grey.shade300,
          ),
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

class _PeriodCard extends StatelessWidget {
  final PayrollPeriodModel period;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _PeriodCard({
    required this.period,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    period.periodName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: period.isOpen
                        ? AppTheme.secondary.withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    period.statusLabel,
                    style: TextStyle(
                      color: period.isOpen
                          ? AppTheme.secondary
                          : AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tanggal
            Row(
              children: [
                const Icon(Icons.date_range_outlined,
                    size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text(
                  '${Formatters.date(period.startDate)} — ${Formatters.date(period.endDate)}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            if (period.notes != null && period.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                period.notes!,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12),
              ),
            ],

            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Toggle status
                TextButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(
                    period.isOpen
                        ? Icons.lock_outline
                        : Icons.lock_open_outlined,
                    size: 16,
                  ),
                  label: Text(period.isOpen ? 'Tutup' : 'Buka'),
                  style: TextButton.styleFrom(
                    foregroundColor: period.isOpen
                        ? AppTheme.warning
                        : AppTheme.secondary,
                  ),
                ),

                if (period.isOpen) ...[
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary),
                  ),
                ],

                TextButton.icon(
                  onPressed: onDelete,
                  icon:
                      const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Hapus'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}