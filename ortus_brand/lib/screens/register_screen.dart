import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Добавлено: ключ для формы для обработки валидации
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Функция для валидации пароля (Исправлен regex для совместимости с Dart/Flutter)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите пароль.';
    }
    if (value.length < 8) {
      return 'Пароль должен содержать минимум 8 символов.';
    }
    // Проверка на заглавную букву
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Пароль должен содержать хотя бы одну заглавную букву.';
    }
    // Проверка на специальный символ (используется безопасный поднабор спецсимволов)
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Пароль должен содержать хотя бы один специальный символ.';
    }
    return null;
  }

  // Общая функция для валидации на пустоту
  String? _validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Поле "$fieldName" не может быть пустым.';
    }
    return null;
  }

  void _register() async {
    // Добавлено: Вызов валидации формы перед регистрацией
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/shop');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка регистрации')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 12),
              const Text(
                'Регистрация',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // Обернуто в Form для валидации
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Заменено на TextFormField и добавлен валидатор
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.black),
                      decoration: InputDecoration(
                        hintText: 'ФИО',
                        hintStyle: const TextStyle(color: AppColors.black),
                        filled: true,
                        fillColor: AppColors.grey.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => _validateNonEmpty(value, 'ФИО'),
                    ),
                    const SizedBox(height: 16),
                    // Заменено на TextFormField и добавлен валидатор
                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: AppColors.black),
                      decoration: InputDecoration(
                        hintText: 'Номер телефона',
                        hintStyle: const TextStyle(color: AppColors.black),
                        filled: true,
                        fillColor: AppColors.grey.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          _validateNonEmpty(value, 'Номер телефона'),
                    ),
                    const SizedBox(height: 16),
                    // Заменено на TextFormField и добавлен валидатор
                    TextFormField(
                      controller: _emailController,
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
                      validator: (value) => _validateNonEmpty(value, 'Email'),
                    ),
                    const SizedBox(height: 16),
                    // Заменено на TextFormField и добавлен валидатор для пароля
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: AppColors.black),
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Пароль',
                        hintStyle: const TextStyle(color: AppColors.black),
                        filled: true,
                        fillColor: AppColors.grey.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorMaxLines: 3,
                      ),
                      validator:
                          _validatePassword, // Используется исправленная функция валидации
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Зарегистрироваться',
                      onPressed: _register,
                      isLoading: authProvider.isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Уже есть аккаунт? Войти',
                  style: TextStyle(color: AppColors.primary, fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
