import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_theme.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/onboarding/presentation/onboarding_screen.dart';
import 'package:rateby/features/settings/application/appearance_providers.dart';
import 'package:rateby/features/shell/presentation/main_shell.dart';
import 'package:rateby/features/shell/presentation/widgets/app_sync_listener.dart';

/// Root widget: theme, Arabic locale (RTL) and the first screen.
///
/// Colors come from a global palette ([AppColors]) rather than from the
/// widget tree, so a change of look has to rebuild everything below. The
/// [MaterialApp] is keyed on the brightness for exactly that reason.
class RatebyApp extends ConsumerStatefulWidget {
  const RatebyApp({super.key});

  @override
  ConsumerState<RatebyApp> createState() => _RatebyAppState();
}

class _RatebyAppState extends ConsumerState<RatebyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The phone switched between light and dark (matters in "system" mode).
  @override
  void didChangePlatformBrightness() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appearanceModeProvider);
    final brightness = resolveBrightness(
      mode,
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
    // Must happen before any child builds.
    AppColors.use(brightness);
    final isDark = brightness == Brightness.dark;

    return MaterialApp(
      key: ValueKey(brightness),
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.forBrightness(brightness),
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: AppColors.surface,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      home: const AppGate(),
    );
  }
}

/// Chooses the first screen: onboarding until a profile exists, then the
/// main shell. Reacts live, so finishing onboarding (or resetting the
/// account in Settings) switches screens without any manual navigation.
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return profile.when(
      skipLoadingOnReload: true,
      loading: () => const Scaffold(body: LoadingView()),
      error: (error, stackTrace) => Scaffold(
        body: ErrorRetryView(onRetry: () => ref.invalidate(profileProvider)),
      ),
      data: (value) =>
          value == null
          ? const OnboardingScreen()
          : const AppSyncListener(child: MainShell()),
    );
  }
}
