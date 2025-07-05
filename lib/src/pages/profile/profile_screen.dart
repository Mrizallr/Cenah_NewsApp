import 'package:flutter/material.dart';
import 'package:cenah_news/src/configs/app_routes.dart';
import 'package:cenah_news/src/provider/auth_provider.dart';
import 'package:provider/provider.dart';
// Import halaman SavedArticlesScreen yang baru
import 'package:cenah_news/src/pages/saved/saved_articles_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isAuthenticated = authProvider.isAuthenticated;
    final isLoading = authProvider.isLoading;

    if (!isAuthenticated) {
      return _buildUnauthenticatedView();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Implementasi pengaturan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur pengaturan akan segera hadir!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh user data if needed
            // await authProvider.refreshUserData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildProfileCard(context, user),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Aktivitas Saya'),
                  const SizedBox(height: 16),
                  _buildActivityOptions(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Pengaturan'),
                  const SizedBox(height: 16),
                  _buildSettingsOptions(context),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context, isLoading),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Anda belum login',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Silakan login untuk mengakses profil Anda',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Login', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, user) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: primaryColor.withOpacity(
                0.1,
              ), // Fixed type error with .withValues()
              backgroundImage:
                  user?.avatar != null && user!.avatar.isNotEmpty
                      ? NetworkImage(user.avatar)
                      : null,
              child:
                  user?.avatar == null || user!.avatar.isEmpty
                      ? Icon(Icons.person, size: 40, color: primaryColor)
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Nama Pengguna',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.title ?? 'Pembaca Berita',
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildActivityOptions(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildOptionTile(context, 'Artikel Saya', Icons.article_outlined, () {
            Navigator.pushNamed(
              context,
              AppRoutes.myArticles,
            ); // Menggunakan rute yang didefinisikan
          }),
          const Divider(height: 1),
          _buildOptionTile(
            context,
            'Artikel Tersimpan',
            Icons.bookmark_outline,
            () {
              // Navigasi ke SavedArticlesScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedArticlesScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            context,
            'Riwayat Bacaan',
            Icons.history_outlined,
            () {
              // Implementasi navigasi ke riwayat bacaan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur riwayat bacaan akan segera hadir!'),
                  duration: Duration(seconds: 2), // Perbaikan di sini
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOptions(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildOptionTile(
            context,
            'Pengaturan Akun',
            Icons.settings_outlined,
            () {
              // Implementasi navigasi ke pengaturan akun
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur pengaturan akun akan segera hadir!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            context,
            'Notifikasi',
            Icons.notifications_outlined,
            () {
              // Implementasi navigasi ke notifikasi
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur notifikasi akan segera hadir!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            context,
            'Bantuan & Dukungan',
            Icons.help_outline,
            () {
              // Implementasi navigasi ke bantuan & dukungan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur bantuan & dukungan akan segera hadir!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            isLoading
                ? null
                : () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
        icon:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
                : const Icon(Icons.logout),
        label: Text(isLoading ? 'Sedang Keluar...' : 'Keluar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
