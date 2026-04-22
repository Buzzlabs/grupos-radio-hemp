import 'package:fluffychat/pages/chat_list/rooms_list/discover_rooms_view.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/widgets/navigation_rail.dart';
import 'package:go_router/go_router.dart';
import 'chat_list_body.dart';
import 'package:fluffychat/widgets/streaming/audio_player_streaming.dart';

class ChatListView extends StatelessWidget {
  final ChatListController controller;

  const ChatListView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !controller.isSearchMode && controller.activeSpaceId == null,
      onPopInvokedWithResult: (pop, _) {
        if (pop) return;
        if (controller.activeSpaceId != null) {
          controller.clearActiveSpace();
          return;
        }
        if (controller.isSearchMode) {
          controller.cancelSearch();
          return;
        }
      },
      child: Row(
        children: [
          if (FluffyThemes.isColumnMode(context) ||
              AppConfig.displayNavigationRail) ...[
            SpacesNavigationRail(
              activeSpaceId: controller.activeSpaceId,
              onGoToChats: controller.clearActiveSpace,
              onGoToSpaceId: controller.setActiveSpace,
            ),
            Container(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ],
          Expanded(
            child: GestureDetector(
              onTap: FocusManager.instance.primaryFocus?.unfocus,
              excludeFromSemantics: true,
              behavior: HitTestBehavior.translucent,
              child: Scaffold(
                  body: Stack(
                children: [
                  ChatListViewBody(controller),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.chatListBackground,
                          ),
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 16,
                            top: 20,
                          ),
                          child: const AudioPlayerStreaming(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 220,
                    right: 12,
                    child: SafeArea(
                      top: false,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor:
                              theme.colorScheme.chatlistDiscoverButtonColor,
                          foregroundColor:
                              theme.colorScheme.chatlistDiscoverButtonTextColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          minimumSize: const Size(130, 25),
                        ),
                        icon: Icon(Icons.explore,
                            color: theme
                                .colorScheme.chatlistDiscoverButtonTextColor),
                        label: Text(
                          'Descobrir Grupos',
                          style: TextStyle(
                              color: theme
                                  .colorScheme.chatlistDiscoverButtonTextColor),
                        ),
                        onPressed: () {
                          context.go('/rooms/discover');
                        },
                      ),
                    ),
                  ),
                ],
              )

                  // floatingActionButton: !controller.isSearchMode &&
                  //         controller.activeSpaceId == null
                  //     ? FloatingActionButton.extended(
                  //         backgroundColor: Theme.of(context).colorScheme.primary,
                  //         foregroundColor: Colors.white,
                  //         elevation: 0,
                  //         onPressed: () => context.go('/rooms/newprivatechat'),
                  //         icon: Icon(
                  //           Icons.add_outlined,
                  //           color: Theme.of(context).colorScheme.onPrimary,
                  //         ),
                  //         label: Text(
                  //           L10n.of(context).chat,
                  //           overflow: TextOverflow.fade,
                  //           style: TextStyle(
                  //             color: Theme.of(context).colorScheme.onPrimary,
                  //             fontSize: 15,
                  //           ),
                  //         ),
                  //       )
                  //     : const SizedBox.shrink(),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
