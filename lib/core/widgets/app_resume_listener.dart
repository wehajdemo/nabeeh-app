import 'package:flutter/widgets.dart';

/// Calls [onResume] once when first shown and every time the app comes back
/// to the foreground (e.g. to pick up a payday that passed meanwhile).
class AppResumeListener extends StatefulWidget {
  const AppResumeListener({
    required this.onResume,
    required this.child,
    super.key,
  });

  final VoidCallback onResume;
  final Widget child;

  @override
  State<AppResumeListener> createState() => _AppResumeListenerState();
}

class _AppResumeListenerState extends State<AppResumeListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onResume();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.onResume();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
