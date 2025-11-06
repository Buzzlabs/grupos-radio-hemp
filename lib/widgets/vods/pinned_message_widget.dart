import 'package:fluffychat/config/themes.dart';
import 'package:flutter/material.dart';

class PinnedMessageWidget extends StatelessWidget {
  final bool enforceMobileMode;
  final VoidCallback? onAcessarPressed;

  const PinnedMessageWidget({
    super.key,
    this.enforceMobileMode = false,
    this.onAcessarPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobileMode =
        enforceMobileMode || !FluffyThemes.isColumnMode(context);

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.push_pin,
                size: 23,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Assista às lives anteriores e veja a programação da Rádio Hemp",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        if (!isMobileMode)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: onAcessarPressed,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                foregroundColor: theme.colorScheme.onSurface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(130, 25),
              ),
              child: Text(
                'Assistir 🎬',
                style: TextStyle(
                  color: theme.colorScheme.onSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: isMobileMode
          ? MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                onTap: onAcessarPressed,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  child: content,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              child: content,
            ),
    );
  }
}
