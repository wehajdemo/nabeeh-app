import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/legal/application/legal_providers.dart';
import 'package:rateby/features/legal/domain/legal_content.dart';
import 'package:rateby/features/legal/presentation/legal_actions.dart';
import 'package:rateby/features/legal/presentation/legal_strings.dart';

/// Shows the privacy policy, the terms or the support page, offline.
class LegalScreen extends ConsumerWidget {
  const LegalScreen({required this.kind, super.key});

  final LegalKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(legalContentProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: BackButton(color: AppColors.onSurface),
        title: Text(
          LegalStrings.title(kind),
          style: AppTypography.headlineSm.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: content.when(
          loading: () => const LoadingView(),
          error: (error, stackTrace) => ErrorRetryView(
            message: LegalStrings.loadFailed,
            onRetry: () => ref.invalidate(legalContentProvider),
          ),
          data: (legal) => _DocumentView(
            document: legal.document(kind),
            showContact: kind == LegalKind.support,
            onContact: () => contactSupport(context, ref),
          ),
        ),
      ),
    );
  }
}

class _DocumentView extends StatelessWidget {
  const _DocumentView({
    required this.document,
    required this.showContact,
    required this.onContact,
  });

  final LegalDocument document;
  final bool showContact;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return ScreenBody(
      children: [
        Text(
          document.intro,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        if (showContact)
          PrimaryButton(
            label: LegalStrings.contactButton,
            icon: Icons.mail_outline,
            onPressed: onContact,
          ),
        for (final section in document.sections) _SectionCard(section: section),
        Text(
          LegalStrings.effective(document.effectiveDate),
          textAlign: TextAlign.center,
          style: AppTypography.labelSm.copyWith(color: AppColors.outline),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          Text(
            section.heading,
            style: AppTypography.labelLg.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          for (final block in section.blocks)
            switch (block) {
              LegalParagraph(:final text) => Text(
                  text,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                ),
              LegalBullets(:final items) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.xs,
                  children: [for (final item in items) _Bullet(text: item)],
                ),
            },
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Dot(color: AppColors.secondary, size: 6),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}
