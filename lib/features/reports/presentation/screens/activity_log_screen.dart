import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/reports/providers/report_provider.dart';
import 'package:mobileremunerationapplication/features/reports/data/models/report_model.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/shared/widgets/loading_widget.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';
import 'package:mobileremunerationapplication/app/routes.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() =>
      _ActivityLogScreenState();
}

class _ActivityLogScreenState
    extends State<ActivityLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadActivityLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Module
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Consumer<ReportProvider>(
              builder: (context, provider, _) =>
                  SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ModuleChip(
                      label: 'Semua',
                      isSelected:
                          provider.moduleFilter == 'all',
                      onTap: () =>
                          provider.setModuleFilter('all'),
                    ),
                    const SizedBox(width: 8),
                    _ModuleChip(
                      label: 'Auth',
                      isSelected:
                          provider.moduleFilter == 'auth',
                      onTap: () =>
                          provider.setModuleFilter('auth'),
                    ),
                    const SizedBox(width: 8),
                    _ModuleChip(
                      label: 'Slip Gaji',
                      isSelected: provider.moduleFilter ==
                          'salary_slip',
                      onTap: () => provider
                          .setModuleFilter('salary_slip'),
                    ),
                    const SizedBox(width: 8),
                    _ModuleChip(
                      label: 'Email',
                      isSelected:
                          provider.moduleFilter == 'email',
                      onTap: () =>
                          provider.setModuleFilter('email'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // List Logs
          Expanded(
            child: Consumer<ReportProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget(
                      message: 'Memuat activity log...');
                }

                if (provider.activityLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_outlined,
                            size: 64,
                            color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada activity log',
                          style: TextStyle(
                              color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      provider.loadActivityLogs(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        provider.activityLogs.length,
                    itemBuilder: (context, index) {
                      final log =
                          provider.activityLogs[index];
                      return _ActivityLogCard(log: log);
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

class _ModuleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModuleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ActivityLogCard extends StatelessWidget {
  final ActivityLogModel log;

  const _ActivityLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: log.actionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color:
                        log.actionColor.withOpacity(0.3)),
              ),
              child: Text(
                log.actionLabel,
                style: TextStyle(
                  color: log.actionColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    log.description,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 12,
                          color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${log.userName} · ${log.userRole}',
                        style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 12,
                          color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.dateTime(log.createdAt),
                        style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11),
                      ),
                      if (log.ipAddress != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.wifi_outlined,
                            size: 12,
                            color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          log.ipAddress!,
                          style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}