import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/utils/fluffy_share.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:fluffychat/widgets/navigation_rail.dart';
import '../../widgets/mxc_image_viewer.dart';
import 'settings.dart';

class SettingsView extends StatelessWidget {
  final SettingsController controller;

  const SettingsView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showChatBackupBanner = controller.showChatBackupBanner;
    final activeRoute =
        GoRouter.of(context).routeInformationProvider.value.uri.path;
    final accountManageUrl = Matrix.of(context)
        .client
        .wellKnown
        ?.additionalProperties
        .tryGetMap<String, Object?>('org.matrix.msc2965.authentication')
        ?.tryGet<String>('account');
    return Row(
      children: [
        if (FluffyThemes.isColumnMode(context)) ...[
          SpacesNavigationRail(
            activeSpaceId: null,
            onGoToChats: () => context.go('/rooms'),
            onGoToSpaceId: (spaceId) => context.go('/rooms?spaceId=$spaceId'),
          ),
          Container(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ],
        Expanded(
          child: Scaffold(
            appBar: FluffyThemes.isColumnMode(context)
                ? null
                : AppBar(
                    title: Text(L10n.of(context).settings,
                    style: TextStyle(color: theme.colorScheme.deviceSettingTitleColor)),
                    leading: Center(
                      child: BackButton(
                        onPressed: () => context.go('/rooms'),
                        color: theme.colorScheme.settingScreenBackButton,
                      ),
                    ),
                  ),
            body: ListTileTheme(
              iconColor: theme.colorScheme.deviceSettingTitleColor,
              child: ListView(
                key: const Key('SettingsListViewContent'),
                children: <Widget>[
                  FutureBuilder<Profile>(
                    future: controller.profileFuture,
                    builder: (context, snapshot) {
                      final profile = snapshot.data;
                      final avatar = profile?.avatarUrl;
                      final mxid = Matrix.of(context).client.userID ??
                          L10n.of(context).user;
                      final displayname =
                          profile?.displayName ?? mxid.localpart ?? mxid;
                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Stack(
                              children: [
                                Avatar(
                                  mxContent: avatar,
                                  name: displayname,
                                  size: Avatar.defaultSize * 2.5,
                                  onTap: avatar != null
                                      ? () => showDialog(
                                            context: context,
                                            builder: (_) =>
                                                MxcImageViewer(avatar),
                                          )
                                      : null,
                                ),
                                if (profile != null)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: FloatingActionButton.small(
                                      backgroundColor:
                                          theme.colorScheme.floatingButtonPaddingColor,
                                      elevation: 2,
                                      onPressed: controller.setAvatarAction,
                                      heroTag: null,
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        color: theme.colorScheme.floatingButtonIconColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  onPressed: controller.setDisplaynameAction,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.participantNameTextColor,
                                    iconColor: theme.colorScheme.participantNameTextColor,
                                  ),
                                  label: Text(
                                    displayname,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: theme.colorScheme.participantNameTextColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      FluffyShare.share(mxid, context),
                                  icon: const Icon(
                                    Icons.copy_outlined,
                                    size: 14,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.settingTextColor,
                                    iconColor: theme.colorScheme.floatingButtonIconColor,
                                  ),
                                  label: Text(
                                    mxid,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    //    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (accountManageUrl != null)
                    ListTile(
                      leading: Icon(Icons.account_circle_outlined, color: theme.colorScheme.floatingButtonIconColor),
                      title: Text(L10n.of(context).manageAccount, style: TextStyle(color: theme.colorScheme.settingTextColor)),
                      trailing: Icon(Icons.open_in_new_outlined, color: theme.colorScheme.floatingButtonIconColor),
                      onTap: () => launchUrlString(
                        accountManageUrl,
                        mode: LaunchMode.inAppBrowserView,
                      ),
                    ),
                  Divider(
                    color: theme.dividerColor,
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.info_outline_rounded),
                  //   title: Text(L10n.of(context).about),
                  //   onTap: () => PlatformInfos.showAboutInfo(context),
                  // ),
                  // Divider(color: theme.dividerColor),
                  ListTile(
                    leading: Icon(Icons.devices_outlined, color: theme.colorScheme.floatingButtonIconColor),
                    title: Text(
                      L10n.of(context).devices,
                      style: TextStyle(color: theme.colorScheme.settingTextColor),
                    ),
                    onTap: () => context.go('/rooms/settings/devices'),
                    tileColor: activeRoute.startsWith('/rooms/settings/devices')
                        ? theme.colorScheme.floatingButtonBackground
                        : null,
                  ),
                  ListTile(
                    leading: Icon(Icons.logout_outlined, color: theme.colorScheme.floatingButtonIconColor),
                    title: Text(
                      L10n.of(context).logout,
                      style: TextStyle(color: theme.colorScheme.settingTextColor),
                    ),
                    onTap: controller.logoutAction,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
