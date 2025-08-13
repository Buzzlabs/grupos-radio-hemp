import 'package:flutter/material.dart';

import 'package:flutter_linkify/flutter_linkify.dart';

import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/utils/url_launcher.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/adaptive_dialog_action.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/dialog_text_field.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String?> showTextInputDialog({
  required BuildContext context,
  required String title,
  String? message,
  String? okLabel,
  String? cancelLabel,
  bool useRootNavigator = true,
  String? hintText,
  String? labelText,
  String? initialText,
  String? prefixText,
  String? suffixText,
  bool obscureText = false,
  bool isDestructive = false,
  int? minLines,
  int? maxLines,
  String? Function(String input)? validator,
  TextInputType? keyboardType,
  int? maxLength,
  bool autocorrect = true,
}) {
  final controller = TextEditingController(text: initialText);
  final theme = Theme.of(context);

  return showAdaptiveDialog<String>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      final error = ValueNotifier<String?>(null);
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 512),
        child: AlertDialog.adaptive(
          title: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 256),
            child: Text(
              title.toUpperCase(),
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 285),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message != null) Text(message),
                const SizedBox(height: 16),
                ValueListenableBuilder<String?>(
                  valueListenable: error,
                  builder: (context, error, _) {
                    return DialogTextField(
                      hintText: hintText,
                      errorText: error,
                      labelText: labelText,
                      controller: controller,
                      initialText: initialText,
                      prefixText: prefixText,
                      suffixText: suffixText,
                      minLines: minLines,
                      maxLines: maxLines,
                      maxLength: maxLength,
                      keyboardType: keyboardType,
                      obscureText: obscureText,
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            AdaptiveDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(cancelLabel ?? L10n.of(context).cancel),
            ),
            AdaptiveDialogAction(
              onPressed: () {
                final input = controller.text;
                final errorText = validator?.call(input);
                if (errorText != null) {
                  error.value = errorText;
                  return;
                }
                Navigator.of(context).pop<String>(input);
              },
              autofocus: true,
              child: Text(
                okLabel ?? L10n.of(context).ok,
                style: isDestructive
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
            ),
          ],
        ),
      );
    },
  );
}
