import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';
import '../../data/models/employee_model.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../app/routes.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
      BuildContext context, EmployeeModel employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Karyawan'),
        content:
            Text('Yakin ingin menghapus "${employee.fullName}"?'),
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
          .read<EmployeeProvider>()
          .deleteEmployee(employee.id);
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
        title: const Text('Data Karyawan'),
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
          await Navigator.pushNamed(context, AppRoutes.employeeCreate);
          if (context.mounted) {
            context.read<EmployeeProvider>().loadEmployees();
          }
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label:
            const Text('Tambah', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, kode karyawan...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<EmployeeProvider>()
                                  .search('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) =>
                      context.read<EmployeeProvider>().search(val),
                ),
                const SizedBox(height: 8),

                // Filter chips
                Consumer<EmployeeProvider>(
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
                        isSelected: provider.statusFilter == 'active',
                        onTap: () => provider.setStatusFilter('active'),
                        color: AppTheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Nonaktif',
                        isSelected: provider.statusFilter == 'inactive',
                        onTap: () =>
                            provider.setStatusFilter('inactive'),
                        color: AppTheme.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: Consumer<EmployeeProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget(
                      message: 'Memuat data karyawan...');
                }

                if (provider.employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('Belum ada data karyawan',
                            style:
                                TextStyle(color: AppTheme.textMuted)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadEmployees(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.employees.length,
                    itemBuilder: (context, index) {
                      final employee = provider.employees[index];
                      return _EmployeeCard(
                        employee: employee,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.employeeDetail,
                          arguments: employee,
                        ),
                        onEdit: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.employeeEdit,
                            arguments: employee,
                          );
                          if (context.mounted) {
                            provider.loadEmployees();
                          }
                        },
                        onDelete: () =>
                            _confirmDelete(context, employee),
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

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.onTap,
    required this.onEdit,
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
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: employee.isActive
                    ? AppTheme.primary.withOpacity(0.1)
                    : Colors.grey.shade200,
                child: Text(
                  employee.initials,
                  style: TextStyle(
                    color: employee.isActive
                        ? AppTheme.primary
                        : AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: employee.isActive
                                ? AppTheme.secondary.withOpacity(0.1)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            employee.statusLabel,
                            style: TextStyle(
                              color: employee.isActive
                                  ? AppTheme.secondary
                                  : AppTheme.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employee.categoryName,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employee.email,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    if (employee.employeeCode != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Kode: ${employee.employeeCode}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit')   onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}