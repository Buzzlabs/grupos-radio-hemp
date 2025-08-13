import 'package:flutter/material.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/adaptive_dialog_action.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/dialog_text_field.dart';

Future<String?> showPasswordWithHintDialog(BuildContext context) {
  final controller = TextEditingController();
  final theme = Theme.of(context);
  final error = ValueNotifier<String?>(null);

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog.adaptive(
        title: Text(L10n.of(context).passwordForgotten.toUpperCase()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.of(context).pleaseUseAStrongPassword,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 12,
              ),
              softWrap: true,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String?>(
              valueListenable: error,
              builder: (context, errorMsg, _) {
                return DialogTextField(
                  hintText: '******',
                  errorText: errorMsg,
                  obscureText: true,
                  controller: controller,
                  minLines: 1,
                  maxLines: 1,
                );
              },
            ),
          ],
        ),
        actions: [
          AdaptiveDialogAction(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(L10n.of(context).cancel),
          ),
          AdaptiveDialogAction(
            onPressed: () {
              final input = controller.text;
              if (!passwordIsValid(input.trim())) {
                error.value = L10n.of(context).pleaseUseAStrongPassword;
                return;
              }
              Navigator.of(context).pop(input);
            },
            child: Text(L10n.of(context).ok),
          ),
        ],
      );
    },
  );
}

bool passwordIsValid(String password) {
  if (password.isEmpty) {
    return false;
  }

  final validPasswordRegex = RegExp(
    r'^(?=.*[0-9])(?=.*[!@#\$%^&*()_+{}\[\]:;<>,.?~\\/-])[A-Za-z\d!@#\$%^&*()_+{}\[\]:;<>,.?~\\/-]{6,}$',
  );

  if (!validPasswordRegex.hasMatch(password)) {
    return false;
  }

  return true;
}
