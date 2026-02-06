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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<CreateGroupType>(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(MaterialState.selected)) {
                        return theme.colorScheme.newGroupSwitchActiveColor;
                      }
                      return theme.colorScheme.newGroupSwitchInactiveColor;
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) {
                      return theme.colorScheme.newGroupOptionsTextColor;
                    },
                  ),
                ),
                selected: {controller.createGroupType},
                onSelectionChanged: controller.setCreateGroupType,
                segments: [
                  ButtonSegment(
                    value: CreateGroupType.group,
                    label: Text(L10n.of(context).group),
                  ),
                  ButtonSegment(
                    value: CreateGroupType.space,
                    label: Text(L10n.of(context).space),
                  ),
                ],
              ),
            ),

            /// ============================
            /// AVATAR
            /// ============================
            InkWell(
              borderRadius: BorderRadius.circular(90),
              onTap: controller.loading ? null : controller.selectPhoto,
              child: CircleAvatar(
                radius: Avatar.defaultSize,
                backgroundColor:
                    theme.colorScheme.newGroupPhotoTemplateBackgroundColor,
                child: avatar == null
                    ? Icon(
                        Icons.add_a_photo_outlined,
                        color: theme.colorScheme.newGroupPhotoTemplateIconColor,
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

            /// ============================
            /// NOME DO GRUPO
            /// ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                style: TextStyle(
                  color: theme.colorScheme.newGroupTextFieldTextColor,
                ),
                autofocus: true,
                controller: controller.nameController,
                autocorrect: false,
                readOnly: controller.loading,
                decoration: InputDecoration(
                  fillColor: theme.colorScheme.newGroupTextFieldFilledColor,
                  prefixIcon: const Icon(Icons.people_outlined),
                  labelText: L10n.of(context).groupName,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ============================
            /// PÚBLICO / PRIVADO
            /// ============================
            SwitchListTile.adaptive(
              inactiveThumbColor: theme.colorScheme.newGroupSwitchActiveColor,
              activeThumbColor: theme.colorScheme.newGroupSwitchInactiveColor,
              inactiveTrackColor: theme.colorScheme.newGroupSwitchInactiveColor,
              activeTrackColor: theme.colorScheme.newGroupSwitchActiveColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              secondary: Icon(
                Icons.public_outlined,
                color: theme.colorScheme.newGroupOptionsTextColor,
              ),
              title: Text(
                L10n.of(context).groupIsPublic,
                style: TextStyle(
                  color: theme.colorScheme.newGroupOptionsTextColor,
                ),
              ),
              value: controller.publicGroup,
              onChanged: controller.loading ? null : controller.setPublicGroup,
            ),

            /// ============================
            /// VISÍVEL / ENCONTRÁVEL
            /// ============================
            SwitchListTile.adaptive(
              inactiveThumbColor: theme.colorScheme.newGroupSwitchActiveColor,
              activeThumbColor: theme.colorScheme.newGroupSwitchInactiveColor,
              inactiveTrackColor: theme.colorScheme.newGroupSwitchInactiveColor,
              activeTrackColor: theme.colorScheme.newGroupSwitchActiveColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              secondary: Icon(
                Icons.search_outlined,
                color: theme.colorScheme.newGroupOptionsTextColor,
              ),
              title: Text(
                L10n.of(context).groupCanBeFoundViaSearch,
                style: TextStyle(
                  color: theme.colorScheme.newGroupOptionsTextColor,
                ),
              ),
              value: controller.groupCanBeFound,
              onChanged:
                  controller.loading ? null : controller.setGroupCanBeFound,
            ),

            /// ============================
            /// KEYWORD (SEMPRE OBRIGATÓRIA)
            /// ============================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              child: TextField(
                style: TextStyle(
                  color: theme.colorScheme.newGroupTextFieldTextColor,
                ),
                controller: controller.keywordController,
                readOnly: controller.loading,
                decoration: InputDecoration(
                  fillColor: theme.colorScheme.newGroupTextFieldFilledColor,
                  prefixIcon: Icon(
                    Icons.tag_outlined,
                    color: controller.keywordAlreadyExists
                        ? theme.colorScheme.error
                        : theme.colorScheme.newGroupTextFieldHintColor,
                  ),
                  labelText: 'keyword',
                  errorText: controller.keywordAlreadyExists
                      ? 'Keyword já está em uso'
                      : null,
                ),
              ),
            ),

            /// ============================
            /// PREÇO (VISÍVEL + PRIVADO)
            /// ============================
            AnimatedSize(
              duration: FluffyThemes.animationDuration,
              curve: FluffyThemes.animationCurve,
              child: controller.groupCanBeFound && !controller.publicGroup
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: theme.colorScheme.newGroupTextFieldTextColor,
                        ),
                        controller: controller.priceController,
                        keyboardType: TextInputType.number,
                        readOnly: controller.loading,
                        decoration: InputDecoration(
                          fillColor:
                              theme.colorScheme.newGroupTextFieldFilledColor,
                          prefixIcon: Icon(
                            Icons.attach_money_outlined,
                            color: theme.colorScheme.newGroupTextFieldHintColor,
                          ),
                          labelText: 'preço',
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            /// ============================
            /// SUBMIT
            /// ============================
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
                          L10n.of(context).createGroupAndInviteUsers,
                        ),
                ),
              ),
            ),

            /// ============================
            /// ERRO
            /// ============================
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
