import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/salary_slip/providers/salary_slip_provider.dart';
import 'package:mobileremunerationapplication/features/employee/providers/employee_provider.dart';
import 'package:mobileremunerationapplication/features/salary_category/providers/salary_category_provider.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/models/payroll_period_model.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';

class SalarySlipFormScreen extends StatefulWidget {
  const SalarySlipFormScreen({super.key});

  @override
  State<SalarySlipFormScreen> createState() =>
      _SalarySlipFormScreenState();
}

class _SalarySlipFormScreenState extends State<SalarySlipFormScreen> {
  final _formKey              = GlobalKey<FormState>();
  final _workingDaysController = TextEditingController(text: '0');
  final _lateCountController   = TextEditingController(text: '0');
  final _bonusController       = TextEditingController(text: '0');
  final _deductionController   = TextEditingController(text: '0');
  final _notesController       = TextEditingController();

  int?  _selectedEmployeeId;
  int?  _selectedCategoryId;
  bool  _isSaving = false;
  PayrollPeriodModel? _period;

  // Simulasi kalkulasi preview
  double _previewTotal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
      context.read<SalaryCategoryProvider>().loadCategories();
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
    _workingDaysController.dispose();
    _lateCountController.dispose();
    _bonusController.dispose();
    _deductionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final categories =
        context.read<SalaryCategoryProvider>().categories;
    final selected = categories
        .where((c) => c.id == _selectedCategoryId)
        .toList();

    if (selected.isEmpty) return;

    final cat        = selected.first;
    final lateCount  = int.tryParse(_lateCountController.text) ?? 0;
    final bonus      = double.tryParse(_bonusController.text) ?? 0;
    final deduction  = double.tryParse(_deductionController.text) ?? 0;

    final total = cat.baseSalary
        + cat.allowance
        + bonus
        - (lateCount * cat.latePenalty)
        - deduction;

    setState(() => _previewTotal = total < 0 ? 0 : total);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEmployeeId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Karyawan dan kategori wajib dipilih'),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      'period_id':            _period?.id,
      'employee_id':          _selectedEmployeeId,
      'category_id':          _selectedCategoryId,
      'total_working_days':   int.tryParse(_workingDaysController.text) ?? 0,
      'late_count':           int.tryParse(_lateCountController.text) ?? 0,
      'bonus':                double.tryParse(_bonusController.text) ?? 0,
      'additional_deduction': double.tryParse(_deductionController.text) ?? 0,
      'notes':                _notesController.text.trim(),
    };

    final result =
        await context.read<SalarySlipProvider>().createSlip(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? ''),
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
        title: const Text('Buat Slip Gaji'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Info Periode
              if (_period != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range_outlined,
                          color: AppTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Periode: ${_period!.periodName}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Pilih Karyawan & Kategori
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Data Karyawan',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Dropdown Karyawan
                      Consumer<EmployeeProvider>(
                        builder: (context, empProvider, _) =>
                            DropdownButtonFormField<int>(
                          value: _selectedEmployeeId,
                          decoration: const InputDecoration(
                            labelText: 'Karyawan *',
                            prefixIcon:
                                Icon(Icons.person_outline),
                          ),
                          items: empProvider.employees
                              .map((e) => DropdownMenuItem(
                                    value: e.id,
                                    child: Text(
                                      '${e.fullName} (${e.categoryName})',
                                      style: const TextStyle(
                                          fontSize: 13),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(
                                () => _selectedEmployeeId = val);
                            // Auto-set kategori sesuai karyawan
                            final emp = empProvider.employees
                                .firstWhere((e) => e.id == val,
                                    orElse: () =>
                                        empProvider.employees.first);
                            setState(() {
                              _selectedCategoryId = emp.categoryId;
                            });
                            _updatePreview();
                          },
                          hint: const Text('Pilih karyawan'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dropdown Kategori
                      Consumer<SalaryCategoryProvider>(
                        builder: (context, catProvider, _) =>
                            DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Kategori Gaji *',
                            prefixIcon:
                                Icon(Icons.category_outlined),
                          ),
                          items: catProvider.categories
                              .map((c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.categoryName),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(
                                () => _selectedCategoryId = val);
                            _updatePreview();
                          },
                          hint: const Text('Pilih kategori'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Input Komponen
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Komponen Gaji',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const Divider(),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _workingDaysController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total Hari Masuk *',
                          prefixIcon:
                              Icon(Icons.calendar_today_outlined),
                          suffixText: 'hari',
                        ),
                        validator: (v) => v!.isEmpty
                            ? 'Hari masuk wajib diisi'
                            : null,
                        onChanged: (_) => _updatePreview(),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _lateCountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Keterlambatan',
                          prefixIcon: Icon(Icons.timer_off_outlined),
                          suffixText: 'kali',
                        ),
                        onChanged: (_) => _updatePreview(),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _bonusController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bonus',
                          prefixIcon:
                              Icon(Icons.add_card_outlined),
                          prefixText: 'Rp ',
                        ),
                        onChanged: (_) => _updatePreview(),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _deductionController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Potongan Tambahan',
                          prefixIcon:
                              Icon(Icons.remove_circle_outline),
                          prefixText: 'Rp ',
                        ),
                        onChanged: (_) => _updatePreview(),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Catatan',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Preview Total
              if (_selectedCategoryId != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimasi Total Gaji',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        Formatters.currency(_previewTotal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Buat Slip Gaji'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}