import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobileremunerationapplication/features/auth/providers/auth_provider.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/shared/widgets/loading_widget.dart';
import 'package:mobileremunerationapplication/core/utils/formatters.dart';
import 'package:mobileremunerationapplication/app/routes.dart';

class DashboardHeadScreen extends StatefulWidget {
  const DashboardHeadScreen({super.key});

  @override
  State<DashboardHeadScreen> createState() => _DashboardHeadScreenState();
}

class _DashboardHeadScreenState extends State<DashboardHeadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadHeadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kepala Toko'),
        // hapus baris ini:
        // automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      drawer: _HeadDrawer(),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Memuat dashboard...');
          }

          final summary = provider.headSummary;

          return RefreshIndicator(
            onRefresh: () => provider.loadHeadDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ─────────────────────────
                  _buildGreeting(user?.name ?? 'Kepala Toko',
                      provider.activePeriod?['period_name']),
                  const SizedBox(height: 16),

                  // ── Summary ──────────────────────────
                  if (summary != null) ...[
                    const Text('Ringkasan',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      childAspectRatio: 1.6,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _StatCard(
                          label: 'Total Karyawan',
                          value: '${summary['total_employees'] ?? 0}',
                          icon: Icons.people_outline,
                          color: AppTheme.primary,
                        ),
                        _StatCard(
                          label: 'Total Slip',
                          value: '${summary['total_slips'] ?? 0}',
                          icon: Icons.receipt_long_outlined,
                          color: AppTheme.secondary,
                        ),
                        _StatCard(
                          label: 'Terkirim',
                          value: '${summary['sent_slips'] ?? 0}',
                          icon: Icons.mark_email_read_outlined,
                          color: AppTheme.secondary,
                        ),
                        _StatCard(
                          label: 'Draft',
                          value: '${summary['draft_slips'] ?? 0}',
                          icon: Icons.drafts_outlined,
                          color: AppTheme.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Karyawan per Kategori ────────────
                  if (provider.employeeByCategory.isNotEmpty) ...[
                    const Text('Karyawan per Kategori',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.employeeByCategory.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final cat = provider.employeeByCategory[index];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppTheme.primary.withOpacity(0.1),
                              child: Text(
                                '${cat['employee_count'] ?? 0}',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            title: Text(
                              cat['category_name'] ?? '-',
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Slip Terbaru ─────────────────────
                  if (provider.recentSlips.isNotEmpty) ...[
                    const Text('Slip Gaji Terbaru',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.recentSlips.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final slip = provider.recentSlips[index];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppTheme.primary.withOpacity(0.1),
                              child: Text(
                                (slip.employeeName ?? '?')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              slip.employeeName ?? '-',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              Formatters.currency(slip.totalSalary),
                              style: const TextStyle(
                                color: AppTheme.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: slip.isSent
                                    ? AppTheme.secondary.withOpacity(0.1)
                                    : AppTheme.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                slip.isSent ? 'Terkirim' : 'Draft',
                                style: TextStyle(
                                  color: slip.isSent
                                      ? AppTheme.secondary
                                      : AppTheme.warning,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
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

  Widget _buildGreeting(String name, String? period) {
    final hour = DateTime.now().hour;
    String greeting = 'Selamat Pagi';
    if (hour >= 11 && hour < 15) greeting = 'Selamat Siang';
    if (hour >= 15 && hour < 18) greeting = 'Selamat Sore';
    if (hour >= 18) greeting = 'Selamat Malam';

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
                Text('$greeting,',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 13)),
                const SizedBox(height: 2),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Kepala Toko',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          if (period != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Periode Aktif',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 11)),
                const SizedBox(height: 2),
                Text(period,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
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
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label,
                style:
                    const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _HeadDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            accountName: Text(user?.name ?? ''),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.name ?? 'H').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _DrawerTile(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              onTap: () => Navigator.pop(context)),
          _DrawerTile(
            icon: Icons.people_outline,
            label: 'Data Karyawan',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.employees);
            },
          ),
          _DrawerTile(
            icon: Icons.date_range_outlined,
            label: 'Periode Penggajian',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.payrollPeriods);
            },
          ),
          _DrawerTile(
            icon: Icons.receipt_long_outlined,
            label: 'Slip Gaji',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.salarySlips);
            },
          ),
          _DrawerTile(
            icon: Icons.send_outlined,
            label: 'Kirim Email Massal',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.emailBulkSend);
            },
          ),
          _DrawerTile(
            icon: Icons.history_outlined,
            label: 'Riwayat Email',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.emailHistory);
            },
          ),
          const Divider(),
          _DrawerTile(
            icon: Icons.person_outline,
            label: 'Profil',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          const Spacer(),
          _DrawerTile(
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
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DrawerTile({
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
