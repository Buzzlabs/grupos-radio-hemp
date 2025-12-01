import 'package:flutter/material.dart';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/new_group/new_group.dart';
import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';

class NewGroupView extends StatelessWidget {
  final NewGroupController controller;

  const NewGroupView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final avatar = controller.avatar;
    final error = controller.error;
    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: BackButton(
            onPressed: controller.loading ? null : Navigator.of(context).pop,
            color: theme.colorScheme.tertiary,
          ),
        ),
        title: Text(
          controller.createGroupType == CreateGroupType.space
              ? L10n.of(context).newSpace
              : L10n.of(context).createGroup,
          style: TextStyle(color: theme.colorScheme.tertiary),
        ),
      ),
      body: MaxWidthBody(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<CreateGroupType>(
                selected: {controller.createGroupType},
                onSelectionChanged: controller.setCreateGroupType,
                segments: [
                  ButtonSegment(
                    value: CreateGroupType.group,
                    label: Text(
                      L10n.of(context).group,
                      style: TextStyle(
                        color:
                            controller.createGroupType == CreateGroupType.group
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                  ButtonSegment(
                    value: CreateGroupType.space,
                    label: Text(
                      L10n.of(context).space,
                      style: TextStyle(
                        color:
                            controller.createGroupType == CreateGroupType.space
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(90),
              onTap: controller.loading ? null : controller.selectPhoto,
              child: CircleAvatar(
                radius: Avatar.defaultSize,
                backgroundColor: theme.colorScheme.primary,
                child: avatar == null
                    ? Icon(
                        Icons.add_a_photo_outlined,
                        color: theme.colorScheme.tertiary,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(90),
                        child: Image.memory(
                          avatar,
                          width: Avatar.defaultSize * 2,
                          height: Avatar.defaultSize * 2,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                autofocus: true,
                controller: controller.nameController,
                autocorrect: false,
                readOnly: controller.loading,
                decoration: InputDecoration(
                  fillColor: theme.colorScheme.tertiaryContainer,
                  prefixIcon: Icon(
                    Icons.people_outlined,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  labelText: controller.createGroupType == CreateGroupType.space
                      ? L10n.of(context).spaceName
                      : L10n.of(context).groupName,
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
                ),
                style: TextStyle(color: theme.colorScheme.tertiary),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              secondary: const Icon(
                Icons.public_outlined,
              ),
              title: Text(
                controller.createGroupType == CreateGroupType.space
                    ? L10n.of(context).spaceIsPublic
                    : L10n.of(context).groupIsPublic,
              ),
              value: controller.publicGroup,
              onChanged: controller.loading ? null : controller.setPublicGroup,
            ),
            AnimatedSize(
              duration: FluffyThemes.animationDuration,
              curve: FluffyThemes.animationCurve,
              child: controller.publicGroup
                  ? SwitchListTile.adaptive(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 32),
                      secondary: Icon(
                        Icons.search_outlined,
                        color: theme.colorScheme.tertiary,
                      ),
                      title: Text(
                        L10n.of(context).groupCanBeFoundViaSearch,
                        style: TextStyle(color: theme.colorScheme.tertiary),
                      ),
                      value: controller.groupCanBeFound,
                      onChanged: controller.loading
                          ? null
                          : controller.setGroupCanBeFound,
                    )
                  : const SizedBox.shrink(),
            ),
            AnimatedSize(
              duration: FluffyThemes.animationDuration,
              curve: FluffyThemes.animationCurve,
              child: controller.createGroupType == CreateGroupType.space
                  ? const SizedBox.shrink()
                  : SwitchListTile.adaptive(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 32),
                      secondary: Icon(
                        Icons.lock_outlined,
                        color: theme.colorScheme.tertiary,
                      ),
                      title: Text(
                        L10n.of(context).enableEncryption,
                        style: TextStyle(
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      value: !controller.publicGroup,
                      onChanged: null,
                    ),
            ),
            AnimatedSize(
              duration: FluffyThemes.animationDuration,
              curve: FluffyThemes.animationCurve,
              child: controller.createGroupType == CreateGroupType.space
                  ? ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 32),
                      trailing: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Icon(
                          Icons.info_outlined,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      subtitle: Text(
                        L10n.of(context).newSpaceDescription,
                        style: TextStyle(color: theme.colorScheme.tertiary),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      controller.loading ? null : controller.submitAction,
                  child: controller.loading
                      ? const LinearProgressIndicator()
                      : Text(
                          controller.createGroupType == CreateGroupType.space
                              ? L10n.of(context).createNewSpace
                              : L10n.of(context).createGroupAndInviteUsers,
                          style: TextStyle(color: theme.colorScheme.tertiary),
                        ),
                ),
              ),
            ),
            AnimatedSize(
              duration: FluffyThemes.animationDuration,
              curve: FluffyThemes.animationCurve,
              child: error == null
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: Icon(
                        Icons.warning_outlined,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(
                        error.toLocalizedString(context),
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
