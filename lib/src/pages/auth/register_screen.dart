// ignore_for_file: use_build_context_synchronously

import 'package:cenah_news/src/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _useDefaultAvatar = true;

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userData = {
        "name": _nameController.text,
        "email": _emailController.text,
        "title": _titleController.text,
        "password": _passwordController.text,
        "avatar":
            _useDefaultAvatar
                ? 'https://i.pravatar.cc/150?img=${_nameController.text}'
                : _avatarUrlController.text,
      };

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        bool success = await authProvider.register(userData);

        if (success) {
          _showSuccessDialog();
        } else {
          _showSnackBar("Registrasi gagal - Email mungkin sudah terdaftar");
        }
      } catch (e) {
        _showSnackBar("Terjadi kesalahan: ${e.toString()}");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor:
            isError
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Registrasi Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    Navigator.pop(context); // Kembali ke login
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avatar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _useDefaultAvatar,
              onChanged: (value) {
                setState(() {
                  _useDefaultAvatar = value ?? true;
                });
              },
            ),
            const Text('Gunakan avatar default'),
          ],
        ),
        if (!_useDefaultAvatar) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _avatarUrlController,
            decoration: _inputDecoration('Masukkan URL avatar'),
            keyboardType: TextInputType.url,
            validator: (value) {
              if (!_useDefaultAvatar && (value == null || value.isEmpty)) {
                return 'URL avatar tidak boleh kosong';
              }
              if (!_useDefaultAvatar &&
                  !Uri.tryParse(value!)!.hasAbsolutePath) {
                return 'URL tidak valid';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 8),
        if (_useDefaultAvatar)
          Text(
            'Avatar akan dibuat otomatis berdasarkan nama Anda',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo2.png', width: 170, height: 65),
                const SizedBox(height: 15),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Isi data di bawah untuk mendaftar',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Nama
                const Text(
                  'Nama Lengkap',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Masukkan nama lengkap Anda'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Nama tidak boleh kosong'
                              : null,
                ),
                const SizedBox(height: 16),

                // Title (Profession/Position)
                const Text(
                  'Profesi/Posisi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration(
                    'Contoh: Jurnalis, Editor, dll.',
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Profesi tidak boleh kosong'
                              : null,
                ),
                const SizedBox(height: 16),

                // Email
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('Masukkan email Anda'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Email tidak boleh kosong';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Avatar Section
                _buildAvatarSection(),
                const SizedBox(height: 16),

                // Password
                const Text(
                  'Kata Sandi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    'Masukkan kata sandi Anda',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Kata sandi tidak boleh kosong';
                    if (value.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Konfirmasi Password
                const Text(
                  'Konfirmasi Kata Sandi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: _inputDecoration(
                    'Masukkan ulang kata sandi Anda',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed:
                          () => setState(
                            () =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                          ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Konfirmasi kata sandi tidak boleh kosong';
                    if (value != _passwordController.text)
                      return 'Kata sandi tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _submitForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                            : const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 24),

                // Link ke Login
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun? ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 14,
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
      ),
    );
  }
}
