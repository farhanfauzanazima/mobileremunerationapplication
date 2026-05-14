import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobileremunerationapplication/features/auth/providers/auth_provider.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/shared/widgets/loading_widget.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';
import 'package:mobileremunerationapplication/app/routes.dart';

class DashboardOwnerScreen extends StatefulWidget {
  const DashboardOwnerScreen({super.key});

  @override
  State<DashboardOwnerScreen> createState() => _DashboardOwnerScreenState();
}

class _DashboardOwnerScreenState extends State<DashboardOwnerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadOwnerDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Owner'),
        // hapus baris ini:
        // automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      drawer: _OwnerDrawer(),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Memuat dashboard...');
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadOwnerDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ────────────────────────
                  _GreetingCard(
                    name: user?.name ?? 'Owner',
                    role: 'Owner',
                    activePeriod: provider.activePeriod?['period_name'],
                  ),
                  const SizedBox(height: 16),

                  // ── Summary Cards ────────────────────
                  if (provider.ownerSummary != null) ...[
                    const Text('Ringkasan Periode Ini',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      childAspectRatio: 1.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _SummaryCard(
                          label: 'Total Karyawan',
                          value:
                              '${provider.ownerSummary!.totalActiveEmployees}',
                          icon: Icons.people_outline,
                          color: AppTheme.primary,
                        ),
                        _SummaryCard(
                          label: 'Total Pengeluaran',
                          value: Formatters.currency(
                              provider.ownerSummary!.totalSalaryThisPeriod),
                          icon: Icons.payments_outlined,
                          color: AppTheme.secondary,
                        ),
                        _SummaryCard(
                          label: 'Slip Terkirim',
                          value:
                              '${provider.ownerSummary!.sentSlipsThisPeriod}',
                          icon: Icons.mark_email_read_outlined,
                          color: AppTheme.secondary,
                        ),
                        _SummaryCard(
                          label: 'Slip Draft',
                          value:
                              '${provider.ownerSummary!.draftSlipsThisPeriod}',
                          icon: Icons.drafts_outlined,
                          color: AppTheme.warning,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // ── Email Stats ──────────────────────
                  if (provider.emailStats != null) ...[
                    const Text('Status Email Periode Ini',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _EmailStatBox(
                                label: 'Terkirim',
                                value: '${provider.emailStats!['sent'] ?? 0}',
                                color: AppTheme.secondary,
                              ),
                            ),
                            Expanded(
                              child: _EmailStatBox(
                                label: 'Gagal',
                                value: '${provider.emailStats!['failed'] ?? 0}',
                                color: AppTheme.accent,
                              ),
                            ),
                            Expanded(
                              child: _EmailStatBox(
                                label: 'Pending',
                                value:
                                    '${provider.emailStats!['pending'] ?? 0}',
                                color: AppTheme.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Kategori Stats ───────────────────
                  if (provider.categoryStats.isNotEmpty) ...[
                    const Text('Karyawan per Kategori',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.categoryStats.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final cat = provider.categoryStats[index];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppTheme.primary.withOpacity(0.1),
                              child: Text(
                                '${cat.employeeCount}',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            title: Text(cat.categoryName,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                            trailing: Text(
                              Formatters.currency(cat.baseSalary),
                              style: const TextStyle(
                                color: AppTheme.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Tren Gaji ────────────────────────
                  if (provider.salaryTrend.isNotEmpty) ...[
                    const Text('Tren Pengeluaran Gaji',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.salaryTrend.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final trend = provider.salaryTrend[index];
                          return ListTile(
                            title: Text(trend.periodName,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                            subtitle: Text(
                              '${trend.totalSlips} karyawan',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.textMuted),
                            ),
                            trailing: Text(
                              Formatters.currency(trend.totalSalary),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Owner Drawer ────────────────────────────────────────────────

class _OwnerDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            accountName: Text(user?.name ?? 'Owner'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.name ?? 'O').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            onTap: () => Navigator.pop(context),
          ),
          _DrawerItem(
            icon: Icons.category_outlined,
            label: 'Kategori Gaji',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.salaryCategories);
            },
          ),
          _DrawerItem(
            icon: Icons.people_outline,
            label: 'Data Karyawan',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.employees);
            },
          ),
          _DrawerItem(
            icon: Icons.date_range_outlined,
            label: 'Periode Penggajian',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.payrollPeriods);
            },
          ),
          _DrawerItem(
            icon: Icons.receipt_long_outlined,
            label: 'Slip Gaji',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.salarySlips);
            },
          ),
          _DrawerItem(
            icon: Icons.send_outlined,
            label: 'Kirim Email Massal',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.emailBulkSend);
            },
          ),
          _DrawerItem(
            icon: Icons.history_outlined,
            label: 'Riwayat Email',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.emailHistory);
            },
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.person_outline,
            label: 'Profil',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          const Spacer(),
          _DrawerItem(
            icon: Icons.logout,
            label: 'Logout',
            color: AppTheme.accent,
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
          const SizedBox(height: 16),
          _DrawerItem(
            icon: Icons.bar_chart_outlined,
            label: 'Laporan Gaji',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.reports);
            },
          ),
          _DrawerItem(
            icon: Icons.analytics_outlined,
            label: 'Statistik',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.statistics);
            },
          ),
          _DrawerItem(
            icon: Icons.manage_search_outlined,
            label: 'Activity Log',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.activityLog);
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
      dense: true,
    );
  }
}

// ── Widget Helpers ──────────────────────────────────────────────

class _GreetingCard extends StatelessWidget {
  final String name;
  final String role;
  final String? activePeriod;

  const _GreetingCard({
    required this.name,
    required this.role,
    this.activePeriod,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF3D5A73)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (activePeriod != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Periode Aktif',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activePeriod!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _EmailStatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
