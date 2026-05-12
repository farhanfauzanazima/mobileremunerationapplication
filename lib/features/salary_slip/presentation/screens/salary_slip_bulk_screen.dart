import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/salary_slip/providers/salary_slip_provider.dart';
import 'package:mobileremunerationapplication/features/employee/providers/employee_provider.dart';
import 'package:mobileremunerationapplication/features/employee/data/models/employee_model.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/models/payroll_period_model.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';

class SalarySlipBulkScreen extends StatefulWidget {
  const SalarySlipBulkScreen({super.key});

  @override
  State<SalarySlipBulkScreen> createState() =>
      _SalarySlipBulkScreenState();
}

class _SalarySlipBulkScreenState extends State<SalarySlipBulkScreen> {
  PayrollPeriodModel? _period;
  bool _isGenerating = false;

  // Map employeeId -> controller values
  final Map<int, TextEditingController> _workingDaysControllers = {};
  final Map<int, TextEditingController> _lateCountControllers   = {};
  final Map<int, TextEditingController> _bonusControllers       = {};
  final Map<int, TextEditingController> _deductionControllers   = {};
  final Set<int> _selectedEmployees = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is PayrollPeriodModel && _period == null) {
      _period = args;
    }
  }

  @override
  void dispose() {
    _workingDaysControllers.values.forEach((c) => c.dispose());
    _lateCountControllers.values.forEach((c) => c.dispose());
    _bonusControllers.values.forEach((c) => c.dispose());
    _deductionControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _initControllers(int employeeId) {
    if (!_workingDaysControllers.containsKey(employeeId)) {
      _workingDaysControllers[employeeId] =
          TextEditingController(text: '0');
      _lateCountControllers[employeeId] =
          TextEditingController(text: '0');
      _bonusControllers[employeeId] =
          TextEditingController(text: '0');
      _deductionControllers[employeeId] =
          TextEditingController(text: '0');
    }
  }

  Future<void> _generate() async {
    if (_selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 karyawan'),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final employees = context
        .read<EmployeeProvider>()
        .employees
        .where((e) => _selectedEmployees.contains(e.id))
        .toList();

    final employeePayloads = employees.map((e) {
      return {
        'employee_id':          e.id,
        'category_id':          e.categoryId,
        'total_working_days':
            int.tryParse(_workingDaysControllers[e.id]?.text ?? '0') ?? 0,
        'late_count':
            int.tryParse(_lateCountControllers[e.id]?.text ?? '0') ?? 0,
        'bonus':
            double.tryParse(_bonusControllers[e.id]?.text ?? '0') ?? 0,
        'additional_deduction':
            double.tryParse(_deductionControllers[e.id]?.text ?? '0') ?? 0,
      };
    }).toList();

    final payload = {
      'period_id': _period?.id,
      'employees': employeePayloads,
    };

    final result =
        await context.read<SalarySlipProvider>().bulkGenerate(payload);

    if (!mounted) return;
    setState(() => _isGenerating = false);

    final summary = result['data']?['summary'];
    final message = summary != null
        ? '${summary['success']} slip berhasil, ${summary['failed']} gagal'
        : result['message'] ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: result['success'] == true
            ? AppTheme.secondary
            : AppTheme.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (result['success'] == true) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Generate Slip'),
        actions: [
          TextButton(
            onPressed: _isGenerating ? null : _generate,
            child: _isGenerating
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Generate',
                    style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Periode
          if (_period != null)
            Container(
              width: double.infinity,
              color: AppTheme.primary.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Text(
                'Periode: ${_period!.periodName}',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Pilih Semua
          Consumer<EmployeeProvider>(
            builder: (context, empProvider, _) => CheckboxListTile(
              title: Text(
                'Pilih Semua (${empProvider.employees.length} karyawan aktif)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              value: _selectedEmployees.length ==
                  empProvider.employees.length,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    for (final e in empProvider.employees) {
                      _selectedEmployees.add(e.id);
                      _initControllers(e.id);
                    }
                  } else {
                    _selectedEmployees.clear();
                  }
                });
              },
              activeColor: AppTheme.primary,
            ),
          ),

          const Divider(height: 1),

          // List Karyawan
          Expanded(
            child: Consumer<EmployeeProvider>(
              builder: (context, empProvider, _) {
                final employees = empProvider.employees
                    .where((e) => e.isActive)
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    final isSelected =
                        _selectedEmployees.contains(employee.id);

                    if (isSelected) _initControllers(employee.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: Text(
                              employee.fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            subtitle: Text(
                              employee.categoryName,
                              style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12),
                            ),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedEmployees.add(employee.id);
                                  _initControllers(employee.id);
                                } else {
                                  _selectedEmployees
                                      .remove(employee.id);
                                }
                              });
                            },
                            activeColor: AppTheme.primary,
                          ),

                          // Input fields jika dipilih
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 0, 16, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _CompactField(
                                      controller:
                                          _workingDaysControllers[
                                              employee.id]!,
                                      label: 'Hari',
                                      suffix: 'hr',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _CompactField(
                                      controller:
                                          _lateCountControllers[
                                              employee.id]!,
                                      label: 'Terlambat',
                                      suffix: 'x',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _CompactField(
                                      controller: _bonusControllers[
                                          employee.id]!,
                                      label: 'Bonus',
                                      prefix: 'Rp',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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

class _CompactField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final String? prefix;

  const _CompactField({
    required this.controller,
    required this.label,
    this.suffix,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        suffixText: suffix,
        prefixText: prefix,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }
}