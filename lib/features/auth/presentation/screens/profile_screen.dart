import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../app/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey  = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController      = TextEditingController();
  final _confirmPasswordController  = TextEditingController();

  bool _isEditingProfile = false;
  bool _isSavingProfile  = false;
  bool _isChangingPass   = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController  = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _isSavingProfile = true);

    final result = await context.read<AuthProvider>().updateProfile(
      name:  _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _isSavingProfile  = false;
      _isEditingProfile = false;
    });

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

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isChangingPass = true);

    final result = await context.read<AuthProvider>().changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword:     _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isChangingPass = false);

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
      // Password berhasil diubah — paksa logout
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar & Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? '-',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '-',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user?.roleLabel ?? '-',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Form Edit Profil
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Informasi Profil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_isEditingProfile)
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => _isEditingProfile = true),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                          ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Form(
                      key: _profileFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            enabled: _isEditingProfile,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Nama wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            enabled: _isEditingProfile,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Email wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            enabled: _isEditingProfile,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Nomor Telepon',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          if (_isEditingProfile) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => setState(
                                        () => _isEditingProfile = false),
                                    child: const Text('Batal'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        _isSavingProfile ? null : _saveProfile,
                                    child: _isSavingProfile
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Simpan'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Form Ganti Password
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ganti Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password Lama',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Password lama wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password Baru',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (v) {
                              if (v!.isEmpty) return 'Password baru wajib diisi';
                              if (v.length < 6) return 'Minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Konfirmasi Password Baru',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (v) {
                              if (v!.isEmpty) return 'Konfirmasi password wajib diisi';
                              if (v != _newPasswordController.text) {
                                return 'Password tidak cocok';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isChangingPass ? null : _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warning,
                            ),
                            child: _isChangingPass
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Ganti Password'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}