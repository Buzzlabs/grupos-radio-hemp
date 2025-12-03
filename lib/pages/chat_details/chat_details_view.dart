import 'package:fluffychat/config/themes.dart';
import 'package:flutter/material.dart';

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/chat_details/chat_details.dart';
import 'package:fluffychat/pages/chat_details/participant_list_item.dart';
import 'package:fluffychat/utils/fluffy_share.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/chat_settings_popup_menu.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import '../../utils/url_launcher.dart';
import '../../widgets/mxc_image_viewer.dart';
import '../../widgets/qr_code_viewer.dart';

class ChatDetailsView extends StatelessWidget {
  final ChatDetailsController controller;

  const ChatDetailsView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final room = Matrix.of(context).client.getRoomById(controller.roomId!);
    if (room == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(L10n.of(context).oopsSomethingWentWrong,
              style: TextStyle(color: theme.colorScheme.oopsMessageTextColor),),
        ),
        body: Center(
          child: Text(L10n.of(context).youAreNoLongerParticipatingInThisChat,
              style: TextStyle(color: theme.colorScheme.oopsMessageTextColor),),
        ),
      );
    }

    final directChatMatrixID = room.directChatMatrixID;
    final roomAvatar = room.avatar;

    return StreamBuilder(
      stream: room.client.onRoomState.stream
          .where((update) => update.roomId == room.id),
      builder: (context, snapshot) {
        var members = room.getParticipants().toList()
          ..sort((b, a) => a.powerLevel.compareTo(b.powerLevel));
        members = members.take(10).toList();
        final actualMembersCount = (room.summary.mInvitedMemberCount ?? 0) +
            (room.summary.mJoinedMemberCount ?? 0);
        final canRequestMoreMembers = members.length < actualMembersCount;
        final iconColor = theme.textTheme.bodyLarge!.color;
        final displayname = room.getLocalizedDisplayname(
          MatrixLocals(L10n.of(context)),
        );
        return Scaffold(
          appBar: AppBar(
            leading: controller.widget.embeddedCloseButton ??
                Center(child: BackButton(color: theme.colorScheme.detailsBackButtonColor)),
            elevation: theme.appBarTheme.elevation,
            actions: <Widget>[
              if (room.canonicalAlias.isNotEmpty)
                IconButton(
                  tooltip: L10n.of(context).share,
                  icon: Icon(Icons.qr_code_rounded,
                      color: theme.colorScheme.detailsIconColor,),
                  onPressed: () => showQrCodeViewer(
                    context,
                    room.canonicalAlias,
                  ),
                )
              else if (directChatMatrixID != null)
                IconButton(
                  tooltip: L10n.of(context).share,
                  icon: Icon(Icons.qr_code_rounded,
                      color: theme.colorScheme.detailsIconColor,),
                  onPressed: () => showQrCodeViewer(
                    context,
                    directChatMatrixID,
                  ),
                ),
              if (controller.widget.embeddedCloseButton == null)
                ChatSettingsPopupMenu(room, false),
            ],
            title: Text(L10n.of(context).chatDetails,
                style: TextStyle(color: theme.colorScheme.detailsTextColor),),
            backgroundColor: theme.appBarTheme.backgroundColor,
          ),
          body: MaxWidthBody(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: members.length + 1 + (canRequestMoreMembers ? 1 : 0),
              itemBuilder: (BuildContext context, int i) => i == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Stack(
                                children: [
                                  Hero(
                                    tag:
                                        controller.widget.embeddedCloseButton !=
                                                null
                                            ? 'embedded_content_banner'
                                            : 'content_banner',
                                    child: Avatar(
                                      mxContent: room.avatar,
                                      name: displayname,
                                      size: Avatar.defaultSize * 2.5,
                                      onTap: roomAvatar != null
                                          ? () => showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    MxcImageViewer(roomAvatar),
                                              )
                                          : null,
                                    ),
                                  ),
                                  if (!room.isDirectChat &&
                                      room.canChangeStateEvent(
                                        EventTypes.RoomAvatar,
                                      ))
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: FloatingActionButton.small(
                                        backgroundColor:
                                            theme.colorScheme.photoChooserButtonPaddingColor,
                                        onPressed: controller.setAvatarAction,
                                        heroTag: null,
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          color: theme.colorScheme.photoChooserButtonIconColor,
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
                                    onPressed: () => room.isDirectChat
                                        ? null
                                        : room.canChangeStateEvent(
                                            EventTypes.RoomName,
                                          )
                                            ? controller.setDisplaynameAction()
                                            : FluffyShare.share(
                                                displayname,
                                                context,
                                                copyOnly: true,
                                              ),
                                    icon: Icon(
                                      room.isDirectChat
                                          ? Icons.chat_bubble_outline
                                          : room.canChangeStateEvent(
                                              EventTypes.RoomName,
                                            )
                                              ? Icons.edit_outlined
                                              : Icons.copy_outlined,
                                      size: 16,
                                      color: theme.colorScheme.detailChatNameTextColor,
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.detailsTextColor,
                                      iconColor: theme.colorScheme.detailsIconColor,
                                    ),
                                    label: Text(
                                      room.isDirectChat
                                          ? L10n.of(context).directChat
                                          : displayname,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: theme.colorScheme.detailFontFamily,
                                        color: theme.colorScheme.detailChatNameTextColor,
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => room.isDirectChat
                                        ? null
                                        : context.push(
                                            '/rooms/${controller.roomId}/details/members',
                                          ),
                                    icon: Icon(
                                      Icons.group_outlined,
                                      size: 14,
                                      color: theme.colorScheme.detailsIconColor,
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.detailsTextColor,
                                      iconColor: theme.colorScheme.detailsIconColor,
                                    ),
                                    label: Text(
                                      L10n.of(context).countParticipants(
                                        actualMembersCount,
                                      ),
                                      style: TextStyle(
                                        color: theme.colorScheme.detailsTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      //    style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: theme.dividerColor),
                        if (!room.canChangeStateEvent(EventTypes.RoomTopic))
                          ListTile(
                            title: Text(
                              L10n.of(context).chatDescription,
                              style: TextStyle(
                                color: theme.colorScheme.detailDescriptionButtonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextButton.icon(
                              onPressed: controller.setTopicAction,
                              label: Text(L10n.of(context).setChatDescription,
                                  style: TextStyle(
                                    color: theme.colorScheme.detailsTextColor,
                                  ),),
                              icon: Icon(
                                Icons.edit_outlined,
                                color: theme.colorScheme.detailsIconColor,
                              ),
                              style: TextButton.styleFrom(
                                iconColor: theme.colorScheme.detailsIconColor,
                                backgroundColor: theme.colorScheme.detailDescriptionButtonColor,
                                foregroundColor: theme.colorScheme.detailsTextColor,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: SelectableLinkify(
                            text: room.topic.isEmpty
                                ? L10n.of(context).noChatDescriptionYet
                                : room.topic,
                            textScaleFactor:
                                MediaQuery.textScalerOf(context).scale(1),
                            options: const LinkifyOptions(humanize: false),
                            linkStyle: const TextStyle(
                              color: Colors.blueAccent,
                              decorationColor: Colors.blueAccent,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: room.topic.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color: theme.colorScheme.detailDescriptionTextColor,
                              decorationColor: theme.colorScheme.detailsIconColor,
                            ),
                            onOpen: (url) =>
                                UrlLauncher(context, url.url).launchUrl(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: theme.dividerColor),
                        if (room.ownPowerLevel == 100)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.scaffoldBackgroundColor,
                              foregroundColor: iconColor,
                              child: Icon(
                                Icons.extension_outlined,
                                color: theme.colorScheme.detailsMainIconColor,
                              ),
                            ),
                            title: Text(L10n.of(context).extensions,
                                style: TextStyle(
                                  fontFamily: theme.colorScheme.detailFontFamily,
                                  color: theme.colorScheme.detailsTextColor,
                                ),),
                            subtitle:
                                Text(L10n.of(context).externalResourcesForRooms,
                                    style: TextStyle(
                                      color: theme.colorScheme.detailsTextColor,
                                    ),),
                            onTap: () => context
                                .push('/rooms/${room.id}/details/extensions'),
                            trailing: Icon(Icons.chevron_right_outlined,
                                color: theme.colorScheme.detailsIconColor,),
                          ),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            foregroundColor: iconColor,
                            child: Icon(
                              Icons.insert_emoticon_outlined,
                              color: theme.colorScheme.photoChooserButtonPaddingColor,
                            ),
                          ),
                          title: Text(L10n.of(context).customEmojisAndStickers,
                              style: TextStyle(
                                fontFamily: theme.colorScheme.detailFontFamily,
                                color: theme.colorScheme.detailsTextColor,
                              ),),
                          subtitle: Text(L10n.of(context).setCustomEmotes,
                              style: TextStyle(
                                color: theme.colorScheme.detailsTextColor,
                              ),),
                          onTap: controller.goToEmoteSettings,
                          trailing: Icon(Icons.chevron_right_outlined,
                              color: theme.colorScheme.detailsIconColor,),
                        ),
                        if (!room.isDirectChat)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.scaffoldBackgroundColor,
                              foregroundColor: iconColor,
                              child: Icon(
                                Icons.shield_outlined,
                                color: theme.colorScheme.detailsMainIconColor,
                              ),
                            ),
                            title: Text(L10n.of(context).accessAndVisibility,
                                style: TextStyle(
                                  fontFamily: theme.colorScheme.detailFontFamily,
                                  color: theme.colorScheme.detailsTextColor,
                                ),),
                            subtitle: Text(
                                L10n.of(context).accessAndVisibilityDescription,
                                style: TextStyle(
                                  color: theme.colorScheme.detailsTextColor,
                                ),),
                            onTap: () => context
                                .push('/rooms/${room.id}/details/access'),
                            trailing: Icon(
                              Icons.chevron_right_outlined,
                              color: theme.colorScheme.detailsIconColor,
                            ),
                          ),
                        if (!room.isDirectChat)
                          ListTile(
                            title: Text(L10n.of(context).chatPermissions,
                                style: TextStyle(
                                  fontFamily: theme.colorScheme.detailFontFamily,
                                  color: theme.colorScheme.detailsTextColor,
                                ),),
                            subtitle:
                                Text(L10n.of(context).whoCanPerformWhichAction,
                                    style: TextStyle(
                                      color: theme.colorScheme.detailsTextColor,
                                    ),),
                            leading: CircleAvatar(
                              backgroundColor: theme.scaffoldBackgroundColor,
                              foregroundColor: iconColor,
                              child: Icon(
                                Icons.edit_attributes_outlined,
                                color: theme.colorScheme.detailsMainIconColor,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_outlined,
                              color: theme.colorScheme.detailsIconColor,
                            ),
                            onTap: () => context
                                .push('/rooms/${room.id}/details/permissions'),
                          ),
                        Divider(color: theme.dividerColor),
                        ListTile(
                          title: Text(
                            L10n.of(context).countParticipants(
                              actualMembersCount,
                            ),
                            style: TextStyle(
                              fontFamily: theme.colorScheme.detailFontFamily,
                              color: theme.colorScheme.detailParticipantsTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!room.isDirectChat && room.canInvite)
                          ListTile(
                            title: Text(L10n.of(context).inviteContact,
                                style: TextStyle(
                                  color: theme.colorScheme.detailsTextColor,
                                ),),
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.detailParticipantsInvitePaddingColor,
                              foregroundColor: theme.colorScheme.detailParticipantsInviteIconColor,
                              radius: Avatar.defaultSize / 2,
                              child: const Icon(Icons.add_outlined),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_outlined,
                              color: theme.colorScheme.detailsIconColor,
                            ),
                            onTap: () => context.go('/rooms/${room.id}/invite'),
                          ),
                      ],
                    )
                  : i < members.length + 1
                      ? ParticipantListItem(members[i - 1])
                      : ListTile(
                          title: Text(
                            L10n.of(context).loadCountMoreParticipants(
                              (actualMembersCount - members.length),
                            ),
                            style: TextStyle(
                                  color: theme.colorScheme.detailsTextColor,
                                ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            child: Icon(
                              Icons.group_outlined,
                              color: theme.colorScheme.detailsMainIconColor,
                            ),
                          ),
                          onTap: () => context.push(
                            '/rooms/${controller.roomId!}/details/members',
                          ),
                          trailing: Icon(
                            Icons.chevron_right_outlined,
                            color: theme.colorScheme.detailsIconColor,
                          ),
                        ),
            ),
          ),
        );
      },
    );
  }
}
