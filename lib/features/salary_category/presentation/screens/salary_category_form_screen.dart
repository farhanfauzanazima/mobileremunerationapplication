import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/salary_category_model.dart';
import '../../providers/salary_category_provider.dart';
import '../../../../../shared/theme/app_theme.dart';

class SalaryCategoryFormScreen extends StatefulWidget {
  const SalaryCategoryFormScreen({super.key});

  @override
  State<SalaryCategoryFormScreen> createState() =>
      _SalaryCategoryFormScreenState();
}

class _SalaryCategoryFormScreenState
    extends State<SalaryCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController        = TextEditingController();
  final _baseSalaryController  = TextEditingController();
  final _allowanceController   = TextEditingController();
  final _overtimeController    = TextEditingController();
  final _latePenaltyController = TextEditingController();
  final _descController        = TextEditingController();

  bool _isActive  = true;
  bool _isSaving  = false;
  bool _isEditing = false;
  SalaryCategoryModel? _editCategory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is SalaryCategoryModel && !_isEditing) {
      _isEditing     = true;
      _editCategory  = args;
      _nameController.text        = args.categoryName;
      _baseSalaryController.text  = args.baseSalary.toStringAsFixed(0);
      _allowanceController.text   = args.allowance.toStringAsFixed(0);
      _overtimeController.text    = args.overtimeRate.toStringAsFixed(0);
      _latePenaltyController.text = args.latePenalty.toStringAsFixed(0);
      _descController.text        = args.description ?? '';
      _isActive                   = args.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseSalaryController.dispose();
    _allowanceController.dispose();
    _overtimeController.dispose();
    _latePenaltyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      'category_name': _nameController.text.trim(),
      'base_salary':   double.tryParse(_baseSalaryController.text) ?? 0,
      'allowance':     double.tryParse(_allowanceController.text) ?? 0,
      'overtime_rate': double.tryParse(_overtimeController.text) ?? 0,
      'late_penalty':  double.tryParse(_latePenaltyController.text) ?? 0,
      'description':   _descController.text.trim(),
      'is_active':     _isActive,
    };

    final provider = context.read<SalaryCategoryProvider>();
    Map<String, dynamic> result;

    if (_isEditing && _editCategory != null) {
      result = await provider.updateCategory(_editCategory!.id, payload);
    } else {
      result = await provider.createCategory(payload);
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

    if (result['success'] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Kategori' : 'Tambah Kategori'),
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
                      const Text('Informasi Kategori',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Nama Kategori
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Kategori *',
                          hintText: 'Contoh: Kategori 1, Magang',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Nama kategori wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Deskripsi
                      TextFormField(
                        controller: _descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Keterangan singkat kategori ini',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Komponen Gaji',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Gaji Pokok
                      TextFormField(
                        controller: _baseSalaryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Gaji Pokok *',
                          hintText: '3000000',
                          prefixIcon: Icon(Icons.payments_outlined),
                          prefixText: 'Rp ',
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Gaji pokok wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Tunjangan
                      TextFormField(
                        controller: _allowanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tunjangan',
                          hintText: '500000',
                          prefixIcon: Icon(Icons.add_card_outlined),
                          prefixText: 'Rp ',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Rate Lembur
                      TextFormField(
                        controller: _overtimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rate Lembur per Jam',
                          hintText: '20000',
                          prefixIcon: Icon(Icons.access_time_outlined),
                          prefixText: 'Rp ',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Potongan Terlambat
                      TextFormField(
                        controller: _latePenaltyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Potongan per Keterlambatan',
                          hintText: '50000',
                          prefixIcon: Icon(Icons.remove_circle_outline),
                          prefixText: 'Rp ',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Status Aktif
              Card(
                child: SwitchListTile(
                  title: const Text('Status Kategori'),
                  subtitle: Text(
                    _isActive ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      color:
                          _isActive ? AppTheme.secondary : AppTheme.textMuted,
                    ),
                  ),
                  value: _isActive,
                  activeColor: AppTheme.secondary,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Kategori'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}