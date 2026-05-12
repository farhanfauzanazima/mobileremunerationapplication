import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/payroll_period/data/models/payroll_period_model.dart';
import 'package:mobileremunerationapplication/features/payroll_period/providers/payroll_period_provider.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';

class PayrollPeriodFormScreen extends StatefulWidget {
  const PayrollPeriodFormScreen({super.key});

  @override
  State<PayrollPeriodFormScreen> createState() =>
      _PayrollPeriodFormScreenState();
}

class _PayrollPeriodFormScreenState
    extends State<PayrollPeriodFormScreen> {
  final _formKey           = GlobalKey<FormState>();
  final _nameController    = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController   = TextEditingController();
  final _notesController   = TextEditingController();

  bool  _isSaving  = false;
  bool  _isEditing = false;
  PayrollPeriodModel? _editPeriod;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is PayrollPeriodModel && !_isEditing) {
      _isEditing                 = true;
      _editPeriod                = args;
      _nameController.text       = args.periodName;
      _startDateController.text  = args.startDate.substring(0, 10);
      _endDateController.text    = args.endDate.substring(0, 10);
      _notesController.text      = args.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = controller.text.isNotEmpty
        ? DateTime.tryParse(controller.text) ?? DateTime.now()
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      'period_name': _nameController.text.trim(),
      'start_date':  _startDateController.text,
      'end_date':    _endDateController.text,
      'notes':       _notesController.text.trim(),
    };

    final provider = context.read<PayrollPeriodProvider>();
    Map<String, dynamic> result;

    if (_isEditing && _editPeriod != null) {
      result = await provider.updatePeriod(_editPeriod!.id, payload);
    } else {
      result = await provider.createPeriod(payload);
    }

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
        title:
            Text(_isEditing ? 'Edit Periode' : 'Tambah Periode'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informasi Periode',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Nama Periode
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Periode *',
                          hintText: 'Contoh: Mei 2026',
                          prefixIcon:
                              Icon(Icons.date_range_outlined),
                        ),
                        validator: (v) => v!.isEmpty
                            ? 'Nama periode wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Tanggal Mulai
                      TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        onTap: () =>
                            _pickDate(_startDateController),
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai *',
                          prefixIcon: Icon(Icons.calendar_today),
                          hintText: 'Pilih tanggal',
                        ),
                        validator: (v) => v!.isEmpty
                            ? 'Tanggal mulai wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Tanggal Selesai
                      TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () => _pickDate(_endDateController),
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Selesai *',
                          prefixIcon: Icon(Icons.calendar_today),
                          hintText: 'Pilih tanggal',
                        ),
                        validator: (v) => v!.isEmpty
                            ? 'Tanggal selesai wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Catatan
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Catatan',
                          prefixIcon: Icon(Icons.notes_outlined),
                          hintText: 'Catatan tambahan (opsional)',
                        ),
                      ),
                    ],
                  ),
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
                    : Text(_isEditing
                        ? 'Simpan Perubahan'
                        : 'Tambah Periode'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}