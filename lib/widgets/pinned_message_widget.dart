import 'package:fluffychat/config/themes.dart';
import 'package:flutter/material.dart';

class PinnedMessageWidget extends StatelessWidget {
  
  final bool enforceMobileMode;


 const PinnedMessageWidget({
    Key? key,
    this.enforceMobileMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
     final isMobileMode =
        enforceMobileMode || !FluffyThemes.isColumnMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.push_pin,
                    size: 23, color: theme.colorScheme.primary),
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
              onPressed: () {
                // Ação ao clicar no botão "Acessar 🔥"
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Botão quadrado
                ),
                backgroundColor: theme.colorScheme.primary
                    .withValues(alpha: 0.2), // <-- Cor de fundo
                foregroundColor:
                    theme.colorScheme.onSurface, // <-- Cor do texto/ícone
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(130, 25), // Botão mais baixo
              ),
              child: Text(
                'Acessar 🔥',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
