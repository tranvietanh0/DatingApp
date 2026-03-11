import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/gradient_scaffold.dart';
import '../../profile/application/profile_providers.dart';
import 'steps/basic_info_step.dart';
import 'steps/bio_step.dart';
import 'steps/interests_step.dart';
import 'steps/location_step.dart';
import 'steps/photos_step.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  static const routeName = 'onboarding';
  static const routePath = '/onboarding';

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  static const _totalSteps = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1 && _pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0 && _pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = ref.watch(profileControllerProvider);
    final isLoading = profileController.isLoading;

    return GradientScaffold(
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(
                onPressed: isLoading ? null : _previousStep,
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        title: _StepIndicator(
          currentStep: _currentStep,
          totalSteps: _totalSteps,
        ),
      ),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [
          BasicInfoStep(onNext: _nextStep),
          InterestsStep(onNext: _nextStep),
          BioStep(onNext: _nextStep),
          PhotosStep(onNext: _nextStep),
          const LocationStep(),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
