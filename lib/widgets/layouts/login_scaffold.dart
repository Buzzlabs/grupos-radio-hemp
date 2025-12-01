import 'package:flutter/material.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/themes.dart';

class LoginScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final bool enforceMobileMode;
  final double maxHeight;

  const LoginScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.enforceMobileMode = false,
    this.maxHeight = 600,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isMobileMode =
        enforceMobileMode || !FluffyThemes.isColumnMode(context);

    if (isMobileMode) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surfaceContainerLow,
              theme.colorScheme.surfaceContainer,
              theme.colorScheme.surfaceContainerHighest,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              color: theme.colorScheme.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                side: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              elevation: theme.appBarTheme.scrolledUnderElevation ?? 4,
              shadowColor: theme.appBarTheme.shadowColor,
              clipBehavior: Clip.hardEdge,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                  maxHeight: 700,
                ),
                child: Scaffold(
                  backgroundColor: theme.colorScheme.tertiary,
                  appBar: appBar,
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: body),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerLow,
            theme.colorScheme.surfaceContainer,
            theme.colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            color: theme.colorScheme.onSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              side: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            elevation: theme.appBarTheme.scrolledUnderElevation ?? 4,
            shadowColor: theme.appBarTheme.shadowColor,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
                maxHeight: 700,
                minWidth: 300,
                minHeight: 400,
              ),
              child: Scaffold(
                backgroundColor: theme.colorScheme.tertiary,
                key: const Key('LoginScaffold'),
                appBar: appBar,
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: body),
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
