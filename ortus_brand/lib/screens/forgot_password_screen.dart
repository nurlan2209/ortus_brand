import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;

  void _sendCode() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите email')));
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService().requestPasswordReset(
      _emailController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result != null && result['error'] == null) {
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Код отправлен на email')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?['error'] ?? 'Ошибка отправки кода')),
      );
    }
  }

  void _resetPassword() async {
    if (_codeController.text.trim().isEmpty ||
        _newPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService().resetPassword(
      _emailController.text.trim(),
      _codeController.text.trim(),
      _newPasswordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result != null && result['error'] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Пароль успешно изменен')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?['error'] ?? 'Ошибка сброса пароля')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 20),
              const Text(
                'Восстановление пароля',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                enabled: !_codeSent,
                style: const TextStyle(color: AppColors.black),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: AppColors.black),
                  filled: true,
                  fillColor: AppColors.grey.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              if (_codeSent) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  style: const TextStyle(color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: 'Код из email',
                    hintStyle: const TextStyle(color: AppColors.black),
                    filled: true,
                    fillColor: AppColors.grey.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: 'Новый пароль',
                    hintStyle: const TextStyle(color: AppColors.black),
                    filled: true,
                    fillColor: AppColors.grey.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              CustomButton(
                text: _codeSent ? 'Изменить пароль' : 'Отправить код',
                onPressed: _codeSent ? _resetPassword : _sendCode,
                isLoading: _isLoading,
              ),
              if (_codeSent) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _codeSent = false),
                  child: const Text(
                    'Отправить код заново',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
