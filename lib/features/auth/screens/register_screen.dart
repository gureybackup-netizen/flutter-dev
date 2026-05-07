import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../services/providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isValidUsername {
    final username = _usernameController.text;
    if (username.length < 3 || username.length > 20) return false;
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(username);
  }

  bool get _isValidPassword {
    return _passwordController.text.length >= 6;
  }

  bool get _passwordsMatch {
    return _passwordController.text == _confirmPasswordController.text;
  }

  Future<void> _register() async {
    if (!_isValidUsername) {
      setState(() => _errorMessage = ErrorMessages.usernameInvalid);
      return;
    }
    if (!_isValidPassword) {
      setState(() => _errorMessage = ErrorMessages.passwordTooShort);
      return;
    }
    if (!_passwordsMatch) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);
    final error = await authService.register(
      username: _usernameController.text.trim().toLowerCase(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        setState(() {
          _errorMessage = error;
        });
      } else {
        context.go(RouteConstants.conversations);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.welcome),
        ),
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Choose a username',
                helperText: '3-20 characters, lowercase letters, numbers, underscores',
                helperMaxLines: 2,
              ),
              autocorrect: false,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'At least 6 characters',
              ),
              obscureText: true,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter password',
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _register(),
              onChanged: (_) => setState(() {}),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}