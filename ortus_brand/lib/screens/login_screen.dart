import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _phoneController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/shop');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Неверные данные')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ), 
              Image.asset('assets/images/logo.png', height: 120),
              const Text(
                'ORTUS BRAND',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              TextField(
                controller: _phoneController,
                style: const TextStyle(color: AppColors.black),
                decoration: InputDecoration(
                  hintText: 'Номер телефона',
                  hintStyle: TextStyle(color: AppColors.black),
                  filled: true,
                  fillColor: AppColors.grey.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: AppColors.black),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Пароль',
                  hintStyle: TextStyle(color: AppColors.black),
                  filled: true,
                  fillColor: AppColors.grey.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Войти',
                onPressed: _login,
                isLoading: authProvider.isLoading,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/forgot-password'),
                child: const Text(
                  'Забыли пароль?',
                  style: TextStyle(color: AppColors.grey, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text(
                  'Регистрация',
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
