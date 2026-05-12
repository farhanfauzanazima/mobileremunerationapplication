import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/employee/data/models/employee_model.dart';
import 'package:mobileremunerationapplication/features/employee/providers/employee_provider.dart';
import 'package:mobileremunerationapplication/features/salary_category/providers/salary_category_provider.dart';
import 'package:mobileremunerationapplication/features/salary_category/data/models/salary_category_model.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';

class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({super.key});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _codeController   = TextEditingController();
  final _emailController  = TextEditingController();
  final _phoneController  = TextEditingController();
  final _joinDateController = TextEditingController();

  int?   _selectedCategoryId;
  String _selectedStatus = 'active';
  bool   _isSaving       = false;
  bool   _isEditing      = false;
  EmployeeModel? _editEmployee;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalaryCategoryProvider>().loadCategories();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is EmployeeModel && !_isEditing) {
      _isEditing             = true;
      _editEmployee          = args;
      _nameController.text   = args.fullName;
      _codeController.text   = args.employeeCode ?? '';
      _emailController.text  = args.email;
      _phoneController.text  = args.phone;
      _joinDateController.text = args.joinDate?.substring(0, 10) ?? '';
      _selectedCategoryId    = args.categoryId;
      _selectedStatus        = args.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _joinDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori gaji wajib dipilih'),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      'full_name':    _nameController.text.trim(),
      'employee_code': _codeController.text.trim().isEmpty
          ? null
          : _codeController.text.trim(),
      'email':       _emailController.text.trim(),
      'phone':       _phoneController.text.trim(),
      'category_id': _selectedCategoryId,
      'join_date':   _joinDateController.text.isEmpty
          ? null
          : _joinDateController.text,
      'status':      _selectedStatus,
    };

    final provider = context.read<EmployeeProvider>();
    Map<String, dynamic> result;

    if (_isEditing && _editEmployee != null) {
      result = await provider.updateEmployee(_editEmployee!.id, payload);
    } else {
      result = await provider.createEmployee(payload);
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
        title: Text(_isEditing ? 'Edit Karyawan' : 'Tambah Karyawan'),
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
                      const Text('Data Karyawan',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const Divider(),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Kode Karyawan',
                          hintText: 'Contoh: EMP001',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v!.isEmpty) return 'Email wajib diisi';
                          if (!v.contains('@'))
                            return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'No. Telepon *',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'No. telepon wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Tanggal Bergabung
                      TextFormField(
                        controller: _joinDateController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Bergabung',
                          prefixIcon:
                              Icon(Icons.calendar_today_outlined),
                          hintText: 'Pilih tanggal',
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
                      const Text('Kategori & Status',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Dropdown Kategori
                      Consumer<SalaryCategoryProvider>(
                        builder: (context, catProvider, _) {
                          return DropdownButtonFormField<int>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Kategori Gaji *',
                              prefixIcon:
                                  Icon(Icons.category_outlined),
                            ),
                            items: catProvider.categories
                                .map((cat) => DropdownMenuItem(
                                      value: cat.id,
                                      child: Text(cat.categoryName),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(
                                () => _selectedCategoryId = val),
                            hint: const Text('Pilih kategori'),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Status
                      if (_isEditing)
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            prefixIcon:
                                Icon(Icons.toggle_on_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'active',
                                child: Text('Aktif')),
                            DropdownMenuItem(
                                value: 'inactive',
                                child: Text('Nonaktif')),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedStatus = val!),
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
                        : 'Tambah Karyawan'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}