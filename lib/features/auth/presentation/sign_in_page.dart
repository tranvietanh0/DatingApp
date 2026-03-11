import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../application/auth_providers.dart';
import '../domain/auth_status.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  static const routeName = 'sign-in';
  static const routePath = '/sign-in';

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authControllerProvider).signInWithGoogle();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = Validators.normalizePhoneNumber(_phoneController.text);
    await ref.read(authControllerProvider).requestOtp(phone);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next.errorMessage != null) {
        _showError(next.errorMessage!);
        next.clearError();
      }
    });

    final authController = ref.watch(authControllerProvider);
    final isLoading = authController.status == AuthStatus.authenticating;
    final theme = Theme.of(context);

    return GradientScaffold(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          children: [
            Text('Meet with intention.', style: theme.textTheme.displayMedium),
            const SizedBox(height: 12),
            Text(
              'Sign in to discover meaningful connections.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            _GoogleSignInCard(
              isLoading: isLoading,
              onPressed: _signInWithGoogle,
            ),
            const SizedBox(height: 16),
            _PhoneSignInCard(
              controller: _phoneController,
              isLoading: isLoading,
              onSubmit: _requestOtp,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleSignInCard extends StatelessWidget {
  const _GoogleSignInCard({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Continue with Google', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Quick sign in with your Google account.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: const Icon(Icons.login_rounded),
                label: const Text('Sign in with Google'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneSignInCard extends StatelessWidget {
  const _PhoneSignInCard({
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Continue with phone', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'We\'ll send you a verification code.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              validator: Validators.phoneNumber,
              onFieldSubmitted: (_) => onSubmit(),
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '0912 345 678',
                prefixIcon: Icon(Icons.phone_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: isLoading ? null : onSubmit,
                icon: const Icon(Icons.sms_rounded),
                label: const Text('Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
