import 'package:flutter/material.dart';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/chat_search/chat_search_files_tab.dart';
import 'package:fluffychat/pages/chat_search/chat_search_images_tab.dart';
import 'package:fluffychat/pages/chat_search/chat_search_message_tab.dart';
import 'package:fluffychat/pages/chat_search/chat_search_page.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';

class ChatSearchView extends StatelessWidget {
  final ChatSearchController controller;

  const ChatSearchView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = controller.room;
    if (room == null) {
      return Scaffold(
        appBar: AppBar(
            title: Text(L10n.of(context).oopsSomethingWentWrong,
                style:
                    TextStyle(color: theme.colorScheme.onSecondaryContainer),),),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(L10n.of(context).youAreNoLongerParticipatingInThisChat,
                style:
                    TextStyle(color: theme.colorScheme.onSecondaryContainer),),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: Center(child: BackButton(color: theme.colorScheme.tertiary)),
        titleSpacing: 0,
        title: Text(
            L10n.of(context).searchIn(
              room.getLocalizedDisplayname(MatrixLocals(
                L10n.of(context),
              ),),
            ),
            style: TextStyle(color: theme.colorScheme.tertiary),),
      ),
      body: MaxWidthBody(
        withScrolling: false,
        child: Column(
          children: [
            if (FluffyThemes.isThreeColumnMode(context))
              const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: TextField(
                controller: controller.searchController,
                onSubmitted: (_) => controller.restartSearch(),
                autofocus: true,
                enabled: controller.tabController.index == 0,
                decoration: InputDecoration(
                  fillColor: theme.colorScheme.tertiaryContainer,
                  hintText: L10n.of(context).search,
                  labelStyle:
                      TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  prefixIcon: Icon(Icons.search_outlined,
                      color: theme.colorScheme.onSecondaryContainer,),
                  disabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: theme.colorScheme.surface, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: TextStyle(
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),
            TabBar(
              controller: controller.tabController,
              tabs: [
                Tab(child: Text(L10n.of(context).messages)),
                Tab(child: Text(L10n.of(context).gallery)),
                Tab(child: Text(L10n.of(context).files)),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.primary.withAlpha(128),
              indicatorColor: theme.colorScheme.primary,
            ),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  ChatSearchMessageTab(
                    searchQuery: controller.searchController.text,
                    room: room,
                    startSearch: controller.startMessageSearch,
                    searchStream: controller.searchStream,
                  ),
                  ChatSearchImagesTab(
                    room: room,
                    startSearch: controller.startGallerySearch,
                    searchStream: controller.galleryStream,
                  ),
                  ChatSearchFilesTab(
                    room: room,
                    startSearch: controller.startFileSearch,
                    searchStream: controller.fileStream,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
