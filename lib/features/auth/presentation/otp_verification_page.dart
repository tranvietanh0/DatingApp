import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../application/auth_providers.dart';
import '../domain/auth_status.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key});

  static const routeName = 'otp-verification';
  static const routePath = '/verify-otp';

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownSeconds = ref.read(authControllerProvider).resendCooldownSeconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = ref.read(authControllerProvider).resendCooldownSeconds;
      if (remaining != _cooldownSeconds) {
        setState(() => _cooldownSeconds = remaining);
      }
      if (remaining == 0) {
        _cooldownTimer?.cancel();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ));
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider).verifyOtp(_otpController.text.trim());
  }

  Future<void> _resendOtp() async {
    await ref.read(authControllerProvider).resendOtp();
    _startCooldownTimer();
    _showSuccess('OTP sent successfully');
  }

  void _goBack() {
    ref.read(authControllerProvider).cancelOtpFlow();
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
    final phoneNumber = authController.pendingPhoneNumber ?? '';
    final theme = Theme.of(context);

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: isLoading ? null : _goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text('Verify your number', style: theme.textTheme.displayMedium),
            const SizedBox(height: 12),
            Text(
              'Enter the 6-digit code sent to $phoneNumber',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      validator: Validators.otpCode,
                      onFieldSubmitted: (_) => _verifyOtp(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        letterSpacing: 8,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: '000000',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : _verifyOtp,
                        icon: const Icon(Icons.verified_rounded),
                        label: const Text('Verify'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ResendButton(
                      cooldownSeconds: _cooldownSeconds,
                      isLoading: isLoading,
                      onPressed: _resendOtp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResendButton extends StatelessWidget {
  const _ResendButton({
    required this.cooldownSeconds,
    required this.isLoading,
    required this.onPressed,
  });

  final int cooldownSeconds;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final canResend = cooldownSeconds == 0 && !isLoading;

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: canResend ? onPressed : null,
        child: Text(
          cooldownSeconds > 0 ? 'Resend code in ${cooldownSeconds}s' : 'Resend code',
        ),
      ),
    );
  }
}
