import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/new_private_chat/new_private_chat.dart';
import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/utils/url_launcher.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import '../../widgets/qr_code_viewer.dart';

class NewPrivateChatView extends StatelessWidget {
  final NewPrivateChatController controller;

  const NewPrivateChatView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final searchResponse = controller.searchResponse;
    final userId = Matrix.of(context).client.userID!;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: Center(
            child: BackButton(
          color: theme.colorScheme.tertiary,
        ),),
        title: Text(
          L10n.of(context).newChat,
          style: TextStyle(color: theme.colorScheme.tertiary),
        ),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          TextButton(
            onPressed:
                UrlLauncher(context, AppConfig.startChatTutorial).launchUrl,
            child: Text(
              L10n.of(context).help,
              style: TextStyle(color: theme.colorScheme.tertiary),
            ),
          ),
        ],
      ),
      body: MaxWidthBody(
        withScrolling: false,
        innerPadding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: controller.controller,
                onChanged: controller.searchUsers,
                decoration: InputDecoration(
                  fillColor: theme.colorScheme.tertiaryContainer,
                  hintText: L10n.of(context).searchForUsers,
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
                  prefixIcon: searchResponse == null
                      ? Icon(
                          Icons.search_outlined,
                          color: theme.colorScheme.onSecondaryContainer,
                        )
                      : FutureBuilder(
                          future: searchResponse,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 1,
                                  ),
                                ),
                              );
                            }
                            return Icon(
                              Icons.search_outlined,
                              color: theme.colorScheme.onSecondaryContainer,
                            );
                          },
                        ),
                  suffixIcon: controller.controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.clear_outlined,
                            color: theme.colorScheme.tertiary,
                          ),
                          onPressed: () {
                            controller.controller.clear();
                            controller.searchUsers();
                          },
                        ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedCrossFade(
                duration: FluffyThemes.animationDuration,
                crossFadeState: searchResponse == null
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: SelectableText.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: L10n.of(context).yourGlobalUserIdIs,
                              style:
                                  TextStyle(color: theme.colorScheme.tertiary),
                            ),
                            TextSpan(
                              text: Matrix.of(context).client.userID,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        style: TextStyle(
                          color: theme.colorScheme.tertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.tertiary,
                        child: Icon(
                          Icons.adaptive.share_outlined,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      title: Text(L10n.of(context).shareInviteLink,
                          style: TextStyle(color: theme.colorScheme.tertiary),),
                      onTap: controller.inviteAction,
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.tertiary,
                        child: Icon(
                          Icons.group_add_outlined,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      title: Text(L10n.of(context).createGroup,
                          style: TextStyle(color: theme.colorScheme.tertiary),),
                      onTap: () => context.go('/rooms/newgroup'),
                    ),
                    if (PlatformInfos.isMobile)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.tertiary,
                          child: Icon(
                            Icons.qr_code_scanner_outlined,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                        title: Text(L10n.of(context).scanQrCode,
                            style:
                                TextStyle(color: theme.colorScheme.tertiary),),
                        onTap: controller.openScannerAction,
                      ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 64.0,
                          vertical: 24.0,
                        ),
                        child: Material(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConfig.borderRadius),
                            side: BorderSide(
                              width: 3,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          color: Colors.transparent,
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(AppConfig.borderRadius),
                            onTap: () => showQrCodeViewer(
                              context,
                              userId,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 200),
                                child: PrettyQrView.data(
                                  data: 'https://matrix.to/#/$userId',
                                  decoration: PrettyQrDecoration(
                                    shape: PrettyQrSmoothSymbol(
                                      roundFactor: 1,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                secondChild: FutureBuilder(
                  future: searchResponse,
                  builder: (context, snapshot) {
                    final result = snapshot.data;
                    final error = snapshot.error;
                    if (error != null) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            error.toLocalizedString(context),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: controller.searchUsers,
                            icon: Icon(
                              Icons.refresh_outlined,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            label: Text(
                              L10n.of(context).tryAgain,
                              style: TextStyle(
                                  color:
                                      theme.colorScheme.onSecondaryContainer,),
                            ),
                          ),
                        ],
                      );
                    }
                    if (result == null) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    if (result.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_outlined,
                            size: 86,
                            color: theme.colorScheme.tertiary,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              L10n.of(context).noUsersFoundWithQuery(
                                controller.controller.text,
                              ),
                              style: TextStyle(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      itemCount: result.length,
                      itemBuilder: (context, i) {
                        final contact = result[i];
                        final displayname = contact.displayName ??
                            contact.userId.localpart ??
                            contact.userId;
                        return ListTile(
                          leading: Avatar(
                            name: displayname,
                            mxContent: contact.avatarUrl,
                            presenceUserId: contact.userId,
                          ),
                          title: Text(
                            displayname,
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                          subtitle: Text(
                            contact.userId,
                            style: TextStyle(color: theme.colorScheme.tertiary),
                          ),
                          onTap: () => controller.openUserModal(contact),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
