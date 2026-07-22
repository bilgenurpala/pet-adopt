import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    bool success;

    if (_isRegisterMode) {
      success = await authProvider.register(
        username: _usernameController.text,
        email: _emailController.text,
        fullName: _fullNameController.text,
        password: _passwordController.text,
      );
    } else {
      success = await authProvider.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }

    if (!mounted) {
      return;
    }

    if (success) {
      context.go(RouteNames.home);
      return;
    }

    final message =
        authProvider.errorMessage ?? 'An unexpected error occurred.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
  }

  void _switchMode() {
    context.read<AuthProvider>().clearError();

    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _obscurePassword = true;
      _obscureConfirmPassword = true;
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required.';
    }

    final emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required.';
    }

    if (password.length < 8) {
      return 'Password must contain at least 8 characters.';
    }

    return null;
  }

  String? _validateUsername(String? value) {
    if (!_isRegisterMode) {
      return null;
    }

    final username = value?.trim() ?? '';

    if (username.isEmpty) {
      return 'Username is required.';
    }

    if (username.length < 3) {
      return 'Username must contain at least 3 characters.';
    }

    return null;
  }

  String? _validateFullName(String? value) {
    if (!_isRegisterMode) {
      return null;
    }

    final fullName = value?.trim() ?? '';

    if (fullName.isEmpty) {
      return 'Full name is required.';
    }

    if (fullName.length < 2) {
      return 'Enter a valid full name.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_isRegisterMode) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Confirm your password.';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 500 ? 24 : 40,
                    vertical: 36,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(
                            Icons.pets,
                            size: 42,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isRegisterMode
                              ? 'Create an account'
                              : 'Welcome back',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRegisterMode
                              ? 'Create your account and start finding pets to adopt.'
                              : 'Sign in to continue your adoption journey.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 32),
                        if (_isRegisterMode) ...[
                          TextFormField(
                            controller: _usernameController,
                            enabled: !authProvider.isLoading,
                            textInputAction: TextInputAction.next,
                            validator: _validateUsername,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _fullNameController,
                            enabled: !authProvider.isLoading,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            validator: _validateFullName,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          enabled: !authProvider.isLoading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: _validateEmail,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !authProvider.isLoading,
                          obscureText: _obscurePassword,
                          textInputAction: _isRegisterMode
                              ? TextInputAction.next
                              : TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          validator: _validatePassword,
                          onFieldSubmitted: (_) {
                            if (!_isRegisterMode) {
                              _submit();
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        if (_isRegisterMode) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            enabled: !authProvider.isLoading,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            validator: _validateConfirmPassword,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Confirm password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _submit,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isRegisterMode
                                      ? 'Create account'
                                      : 'Sign in',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isRegisterMode
                                  ? 'Already have an account?'
                                  : 'Don’t have an account?',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _switchMode,
                              child: Text(
                                _isRegisterMode ? 'Sign in' : 'Register',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
