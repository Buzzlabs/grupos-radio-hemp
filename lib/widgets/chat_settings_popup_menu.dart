import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_ok_cancel_alert_dialog.dart';
import 'package:fluffychat/widgets/future_loading_dialog.dart';
import 'matrix.dart';

enum ChatPopupMenuActions { details, mute, unmute, leave, search }

class ChatSettingsPopupMenu extends StatefulWidget {
  final Room room;
  final bool displayChatDetails;

  const ChatSettingsPopupMenu(this.room, this.displayChatDetails, {super.key});

  @override
  ChatSettingsPopupMenuState createState() => ChatSettingsPopupMenuState();
}

class ChatSettingsPopupMenuState extends State<ChatSettingsPopupMenu> {
  StreamSubscription? notificationChangeSub;

  @override
  void dispose() {
    notificationChangeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    notificationChangeSub ??= Matrix.of(context)
        .client
        .onSync
        .stream
        .where(
          (syncUpdate) =>
              syncUpdate.accountData?.any(
                (accountData) => accountData.type == 'm.push_rules',
              ) ??
              false,
        )
        .listen(
          (u) => setState(() {}),
        );
    return Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox.shrink(),
        PopupMenuButton<ChatPopupMenuActions>(
          icon: Icon(
            Icons.more_vert,
            color: theme.colorScheme.tertiary,
          ),
          color: theme.colorScheme.surface,
          useRootNavigator: true,
          onSelected: (choice) async {
            switch (choice) {
              case ChatPopupMenuActions.leave:
                final router = GoRouter.of(context);

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    final theme = Theme.of(context);

                    return AlertDialog(
                      backgroundColor: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        L10n.of(context).areYouSure,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: Text(
                        L10n.of(context).archiveRoomDescription,
                        style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontSize: 16,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            L10n.of(context).cancel,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            L10n.of(context).leave,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed != true) return;

                final result = await showFutureLoadingDialog(
                  context: context,
                  future: () => widget.room.leave(),
                );

                if (result.error == null) {
                  router.go('/rooms');
                }
                break;
              case ChatPopupMenuActions.mute:
                await showFutureLoadingDialog(
                  context: context,
                  future: () =>
                      widget.room.setPushRuleState(PushRuleState.mentionsOnly),
                );
                break;
              case ChatPopupMenuActions.unmute:
                await showFutureLoadingDialog(
                  context: context,
                  future: () =>
                      widget.room.setPushRuleState(PushRuleState.notify),
                );
                break;
              case ChatPopupMenuActions.details:
                _showChatDetails();
                break;
              case ChatPopupMenuActions.search:
                context.go('/rooms/${widget.room.id}/search');
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            if (widget.displayChatDetails)
              PopupMenuItem<ChatPopupMenuActions>(
                value: ChatPopupMenuActions.details,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 12),
                    Text(L10n.of(context).chatDetails,
                        style: TextStyle(color: theme.colorScheme.tertiary),),
                  ],
                ),
              ),
            if (widget.room.pushRuleState == PushRuleState.notify)
              PopupMenuItem<ChatPopupMenuActions>(
                value: ChatPopupMenuActions.mute,
                child: Row(
                  children: [
                    Icon(Icons.notifications_off_outlined,
                        color: theme.colorScheme.tertiary,),
                    const SizedBox(width: 12),
                    Text(L10n.of(context).muteChat,
                        style: TextStyle(color: theme.colorScheme.tertiary),),
                  ],
                ),
              )
            else
              PopupMenuItem<ChatPopupMenuActions>(
                value: ChatPopupMenuActions.unmute,
                child: Row(
                  children: [
                    Icon(Icons.notifications_on_outlined,
                        color: theme.colorScheme.tertiary,),
                    const SizedBox(width: 12),
                    Text(L10n.of(context).unmuteChat,
                        style: TextStyle(color: theme.colorScheme.tertiary),),
                  ],
                ),
              ),
            PopupMenuItem<ChatPopupMenuActions>(
              value: ChatPopupMenuActions.search,
              child: Row(
                children: [
                  Icon(Icons.search_outlined,
                      color: theme.colorScheme.tertiary,),
                  const SizedBox(width: 12),
                  Text(L10n.of(context).search,
                      style: TextStyle(color: theme.colorScheme.tertiary),),
                ],
              ),
            ),
            PopupMenuItem<ChatPopupMenuActions>(
              value: ChatPopupMenuActions.leave,
              child: Row(
                children: [
                  Icon(Icons.delete_outlined, color: theme.colorScheme.error),
                  const SizedBox(width: 12),
                  Text(L10n.of(context).leave,
                      style: TextStyle(color: theme.colorScheme.error),),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showChatDetails() {
    if (GoRouterState.of(context).uri.path.endsWith('/details')) {
      context.go('/rooms/${widget.room.id}');
    } else {
      context.go('/rooms/${widget.room.id}/details');
    }
  }
}
