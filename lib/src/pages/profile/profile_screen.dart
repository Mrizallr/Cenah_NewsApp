import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// --- Data Dummy ---
  /// Data ini nantinya akan diambil dari state management atau database.
  final Map<String, String> userData = const {
    'name': 'Sarah',
    'email': 'sarah.doe@email.com',
    'avatarUrl': 'assets/images/avatar.png', // Pastikan aset ini ada
  };

  /// --- Fungsi untuk Dialog Konfirmasi Logout ---
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Keluar Akun'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: Text('Keluar', style: TextStyle(color: Colors.red[600])),
              onPressed: () {
                // TODO: Tambahkan logika logout di sini (misal: hapus token, panggil API)
                Navigator.of(dialogContext).pop(); // Tutup dialog
                // Navigator.of(context).pushAndRemoveUntil( ... ke halaman login);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Bagian Header Pengguna ---
            _buildProfileHeader(),
            const SizedBox(height: 32),
            
            // --- Grup Menu: Manajemen Akun ---
            _buildMenuGroup(
              context: context,
              title: 'Manajemen Akun',
              items: [
                _buildProfileMenuItem(
                  icon: Icons.bookmark_border,
                  title: 'Artikel Tersimpan',
                  onTap: () {
                    // TODO: Navigasi ke halaman artikel tersimpan
                  },
                ),
                _buildProfileMenuItem(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profil',
                  onTap: () {
                    // TODO: Navigasi ke halaman edit profil
                  },
                ),
                _buildProfileMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Ubah Kata Sandi',
                  onTap: () {
                    // TODO: Navigasi ke halaman ubah kata sandi
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),

            // --- Tombol Keluar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildProfileMenuItem(
                icon: Icons.logout,
                title: 'Keluar',
                textColor: Colors.red[600],
                onTap: () {
                  _showLogoutConfirmationDialog(context);
                },
                hideArrow: true, // Sembunyikan panah untuk item ini
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk membangun header profil (avatar, nama, email).
  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(userData['avatarUrl']!),
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Text(
          userData['name']!,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userData['email']!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Widget untuk membangun satu grup menu.
  Widget _buildMenuGroup({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk membangun satu item di dalam menu profil.
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    bool hideArrow = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[800]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: hideArrow
          ? null
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
