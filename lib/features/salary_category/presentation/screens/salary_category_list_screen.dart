import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/salary_category_provider.dart';
import '../../data/models/salary_category_model.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../app/routes.dart';
import '../../../../../core/utils/formatters.dart';

class SalaryCategoryListScreen extends StatefulWidget {
  const SalaryCategoryListScreen({super.key});

  @override
  State<SalaryCategoryListScreen> createState() =>
      _SalaryCategoryListScreenState();
}

class _SalaryCategoryListScreenState
    extends State<SalaryCategoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalaryCategoryProvider>().loadCategories();
    });
  }

  Future<void> _confirmDelete(
      BuildContext context, SalaryCategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text(
            'Yakin ingin menghapus kategori "${category.categoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final result = await context
          .read<SalaryCategoryProvider>()
          .deleteCategory(category.id);

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
        title: const Text('Kategori Gaji'),
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
              context, AppRoutes.salaryCategoryCreate);
          if (context.mounted) {
            context.read<SalaryCategoryProvider>().loadCategories();
          }
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah',
            style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<SalaryCategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Memuat kategori gaji...');
          }

          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Belum ada kategori gaji',
                      style: TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.salaryCategoryCreate),
                    child: const Text('Tambah Kategori'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadCategories(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return _CategoryCard(
                  category: category,
                  onEdit: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.salaryCategoryEdit,
                      arguments: category,
                    );
                    if (context.mounted) {
                      provider.loadCategories();
                    }
                  },
                  onDelete: () => _confirmDelete(context, category),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final SalaryCategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
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
                    category.categoryName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: category.isActive
                        ? AppTheme.secondary.withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.isActive ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      color: category.isActive
                          ? AppTheme.secondary
                          : AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),

            // Info gaji
            _InfoRow(
              label: 'Gaji Pokok',
              value: Formatters.currency(category.baseSalary),
              color: AppTheme.secondary,
            ),
            _InfoRow(
              label: 'Tunjangan',
              value: Formatters.currency(category.allowance),
              color: AppTheme.secondary,
            ),
            _InfoRow(
              label: 'Potongan Terlambat',
              value: Formatters.currency(category.latePenalty),
              color: AppTheme.accent,
            ),

            if (category.description != null &&
                category.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                category.description!,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12),
              ),
            ],

            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}