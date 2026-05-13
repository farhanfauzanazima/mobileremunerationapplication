import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/email/providers/email_provider.dart';
import 'package:mobileremunerationapplication/features/salary_slip/providers/salary_slip_provider.dart';
import 'package:mobileremunerationapplication/features/salary_slip/data/models/salary_slip_model.dart';
import 'package:mobileremunerationapplication/features/payroll_period/providers/payroll_period_provider.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/models/payroll_period_model.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/shared/widgets/loading_widget.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';

class EmailBulkSendScreen extends StatefulWidget {
  const EmailBulkSendScreen({super.key});

  @override
  State<EmailBulkSendScreen> createState() =>
      _EmailBulkSendScreenState();
}

class _EmailBulkSendScreenState extends State<EmailBulkSendScreen> {
  PayrollPeriodModel? _selectedPeriod;
  final Set<int> _selectedSlipIds = {};
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PayrollPeriodProvider>().loadPeriods();
      // Auto-pilih periode aktif
      final active =
          context.read<PayrollPeriodProvider>().activePeriod;
      if (active != null) {
        setState(() => _selectedPeriod = active);
        context
            .read<SalarySlipProvider>()
            .loadSlips(periodId: active.id);
      }
    });
  }

  Future<void> _sendEmails() async {
    if (_selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih periode terlebih dahulu'),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final slips = context.read<SalarySlipProvider>().slips;
    final draftSlips =
        slips.where((s) => s.isDraft).toList();

    if (draftSlips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada slip draft untuk dikirim'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final targetSlips = _selectedSlipIds.isEmpty
        ? draftSlips
        : draftSlips
            .where((s) => _selectedSlipIds.contains(s.id))
            .toList();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Kirim Email'),
        content: Text(
          'Email akan dikirim ke ${targetSlips.length} karyawan '
          'untuk periode ${_selectedPeriod!.periodName}.\n\n'
          'Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kirim Semua'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isSending = true);

    final slipIds = _selectedSlipIds.isEmpty
        ? null
        : _selectedSlipIds.toList();

    final result =
        await context.read<EmailProvider>().sendBulkEmail(
              periodId: _selectedPeriod!.id,
              slipIds:  slipIds,
            );

    if (!mounted) return;
    setState(() => _isSending = false);

    final summary = result['data']?['summary'];
    final message = summary != null
        ? '${summary['success']} email terkirim, '
            '${summary['failed']} gagal'
        : result['message'] ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: result['success'] == true
            ? AppTheme.secondary
            : AppTheme.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );

    if (result['success'] == true) {
      context
          .read<SalarySlipProvider>()
          .loadSlips(periodId: _selectedPeriod?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kirim Email Massal'),
        actions: [
          if (_isSending)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _sendEmails,
              child: const Text('Kirim',
                  style: TextStyle(color: Colors.white)),
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
                  prefixIcon: Icon(Icons.date_range_outlined),
                  isDense: true,
                ),
                items: periodProvider.periods
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.periodName} (${p.statusLabel})',
                            style:
                                const TextStyle(fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPeriod = val;
                    _selectedSlipIds.clear();
                  });
                  if (val != null) {
                    context
                        .read<SalarySlipProvider>()
                        .loadSlips(periodId: val.id);
                  }
                },
                hint: const Text('Pilih periode'),
              ),
            ),
          ),

          // Info & Select All
          Consumer<SalarySlipProvider>(
            builder: (context, slipProvider, _) {
              final draftSlips = slipProvider.slips
                  .where((s) => s.isDraft)
                  .toList();

              return Container(
                color: AppTheme.primary.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16,
                        color: AppTheme.primary.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${draftSlips.length} slip draft '
                        '| ${slipProvider.slips.where((s) => s.isSent).length} sudah terkirim',
                        style: TextStyle(
                          color: AppTheme.primary.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedSlipIds.length ==
                              draftSlips.length) {
                            _selectedSlipIds.clear();
                          } else {
                            _selectedSlipIds.addAll(
                                draftSlips.map((s) => s.id));
                          }
                        });
                      },
                      child: Text(
                        _selectedSlipIds.length ==
                                draftSlips.length
                            ? 'Batal Semua'
                            : 'Pilih Semua',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // List Slip
          Expanded(
            child: Consumer<SalarySlipProvider>(
              builder: (context, slipProvider, _) {
                if (slipProvider.isLoading) {
                  return const LoadingWidget(
                      message: 'Memuat slip gaji...');
                }

                if (_selectedPeriod == null) {
                  return const Center(
                    child: Text(
                      'Pilih periode untuk melihat slip gaji',
                      style:
                          TextStyle(color: AppTheme.textMuted),
                    ),
                  );
                }

                if (slipProvider.slips.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada slip gaji di periode ini',
                      style:
                          TextStyle(color: AppTheme.textMuted),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: slipProvider.slips.length,
                  itemBuilder: (context, index) {
                    final slip = slipProvider.slips[index];
                    final isSelected =
                        _selectedSlipIds.contains(slip.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        enabled: slip.isDraft,
                        value: isSelected,
                        onChanged: slip.isDraft
                            ? (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedSlipIds
                                        .add(slip.id);
                                  } else {
                                    _selectedSlipIds
                                        .remove(slip.id);
                                  }
                                });
                              }
                            : null,
                        title: Text(
                          slip.employeeName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              slip.employee?['email'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted),
                            ),
                            Text(
                              Formatters.currency(
                                  slip.totalSalary),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: slip.isSent
                                ? AppTheme.secondary
                                    .withOpacity(0.1)
                                : AppTheme.warning
                                    .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(8),
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
                        activeColor: AppTheme.primary,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}