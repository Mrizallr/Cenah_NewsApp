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

  // Warna utama baru sesuai permintaan Anda
  static final Color _primaryColor = Colors.blueAccent[400]!;

  void _submitForm() async {
    // Sembunyikan keyboard saat submit
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userData = {
        "name": _nameController.text,
        "email": _emailController.text,
        "title": _titleController.text,
        "password": _passwordController.text,
        "avatar":
            _useDefaultAvatar
                ? 'https://i.pravatar.cc/150?u=${_emailController.text}'
                : _avatarUrlController.text,
      };

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        bool success = await authProvider.register(userData);

        if (success) {
          _showSuccessDialog();
        } else {
          _showSnackBar("Registrasi gagal - Email mungkin sudah terdaftar.");
        }
      } catch (e) {
        _showSnackBar("Terjadi kesalahan: ${e.toString()}");
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: _primaryColor,
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Registrasi Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda sekarang bisa masuk dengan akun baru Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    Navigator.of(context).pop(); // Kembali ke login
                  },
                  child: const Text('OK', style: TextStyle(fontSize: 16)),
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

  InputDecoration _inputDecoration(String labelText, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.grey[700]),
      suffixIcon: suffixIcon,
      fillColor: Colors.grey[100],
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildFormField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    validator:
                        (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _titleController,
                    label: 'Profesi/Posisi (Contoh: Jurnalis)',
                    validator:
                        (v) => v!.isEmpty ? 'Profesi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _emailController,
                    label: 'Alamat Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v!.isEmpty) return 'Email tidak boleh kosong';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                        return 'Masukkan email yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildAvatarSection(),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _passwordController,
                    label: 'Kata Sandi',
                    obscureText: _obscurePassword,
                    suffixIcon: _buildTogglePasswordVisibility(
                      _obscurePassword,
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v!.isEmpty) return 'Kata sandi tidak boleh kosong';
                      if (v.length < 6) return 'Kata sandi minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _confirmPasswordController,
                    label: 'Konfirmasi Kata Sandi',
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: _buildTogglePasswordVisibility(
                      _obscureConfirmPassword,
                      () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                    validator:
                        (v) =>
                            v != _passwordController.text
                                ? 'Kata sandi tidak cocok'
                                : null,
                  ),
                  const SizedBox(height: 32),
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/images/logo2.png', height: 60, fit: BoxFit.contain),
        const SizedBox(height: 20),
        const Text(
          'Buat Akun Baru',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Isi data di bawah untuk mendaftar',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, suffixIcon: suffixIcon),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text(
              'Gunakan Avatar Default',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            value: _useDefaultAvatar,
            onChanged: (value) => setState(() => _useDefaultAvatar = value),
            activeColor: _primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                !_useDefaultAvatar
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      child: TextFormField(
                        controller: _avatarUrlController,
                        decoration: _inputDecoration('Masukkan URL Avatar'),
                        keyboardType: TextInputType.url,
                        validator: (v) {
                          if (!_useDefaultAvatar) {
                            if (v == null || v.isEmpty)
                              return 'URL tidak boleh kosong';
                            final uri = Uri.tryParse(v);
                            if (uri == null || !uri.isAbsolute)
                              return 'Masukkan URL yang valid';
                          }
                          return null;
                        },
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTogglePasswordVisibility(
    bool isObscured,
    VoidCallback onPressed,
  ) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: Colors.grey[600],
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          disabledBackgroundColor: _primaryColor.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                : const Text(
                  'Daftar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Sudah punya akun? ", style: TextStyle(color: Colors.grey[600])),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Masuk',
            style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
