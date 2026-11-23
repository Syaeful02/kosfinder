import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/providers/auth_provider.dart';
import 'package:kostfinder/screens/owner/owner_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();
    final success = await provider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted || !success) return;

    if (provider.isAuthenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const OwnerDashboardScreen()),
        (route) => route.isFirst,
      );
    } else {
      setState(() {
        _successMessage =
            'Pendaftaran berhasil. Silakan verifikasi email, lalu masuk.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pemilik')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('register-email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('register-password'),
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _submit(),
                ),
                Consumer<AuthProvider>(
                  builder: (context, provider, _) {
                    final message = provider.errorMessage ?? _successMessage;
                    if (message == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        message,
                        key: Key(
                          provider.errorMessage == null
                              ? 'register-success'
                              : 'register-error',
                        ),
                        style: TextStyle(
                          color: provider.errorMessage == null
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, provider, _) => ElevatedButton(
                    onPressed: provider.isLoading ? null : _submit,
                    child: provider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Daftar'),
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
