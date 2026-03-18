import 'package:fluffychat/config/themes.dart';
import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/utils/url_launcher.dart';
import 'package:fluffychat/widgets/mxc_image.dart';
import '../../widgets/avatar.dart';

class StickerPickerDialog extends StatefulWidget {
  final Room room;
  final void Function(ImagePackImageContent) onSelected;

  const StickerPickerDialog({
    required this.onSelected,
    required this.room,
    super.key,
  });

  @override
  StickerPickerDialogState createState() => StickerPickerDialogState();
}

class StickerPickerDialogState extends State<StickerPickerDialog> {
  String? searchFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final stickerPacks = widget.room.getImagePacks(ImagePackUsage.sticker);
    final packSlugs = stickerPacks.keys.toList();

    // ignore: prefer_function_declarations_over_variables
    final packBuilder = (BuildContext context, int packIndex) {
      final pack = stickerPacks[packSlugs[packIndex]]!;
      final filteredImagePackImageEntried = pack.images.entries.toList();
      if (searchFilter?.isNotEmpty ?? false) {
        filteredImagePackImageEntried.removeWhere(
          (e) => !(e.key.toLowerCase().contains(searchFilter!.toLowerCase()) ||
              (e.value.body
                      ?.toLowerCase()
                      .contains(searchFilter!.toLowerCase()) ??
                  false)),
        );
      }
      final imageKeys =
          filteredImagePackImageEntried.map((e) => e.key).toList();
      if (imageKeys.isEmpty) {
        return const SizedBox.shrink();
      }
      final packName = pack.pack.displayName ?? packSlugs[packIndex];
      return Column(
        children: <Widget>[
          if (packIndex != 0) const SizedBox(height: 20),
          if (packName != 'user')
            ListTile(
              leading: Avatar(
                mxContent: pack.pack.avatarUrl,
                name: packName,
                client: widget.room.client,
              ),
              title: Text(packName),
            ),
          const SizedBox(height: 6),
          GridView.builder(
            itemCount: imageKeys.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 128,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int imageIndex) {
              final image = pack.images[imageKeys[imageIndex]]!;
              return Tooltip(
                message: image.body ?? imageKeys[imageIndex],
                child: InkWell(
                  radius: AppConfig.borderRadius,
                  key: ValueKey(image.url.toString()),
                  onTap: () {
                    // copy the image
                    final imageCopy =
                        ImagePackImageContent.fromJson(image.toJson().copy());
                    // set the body, if it doesn't exist, to the key
                    imageCopy.body ??= imageKeys[imageIndex];
                    widget.onSelected(imageCopy);
                  },
                  child: AbsorbPointer(
                    absorbing: true,
                    child: MxcImage(
                      uri: image.url,
                      fit: BoxFit.contain,
                      width: 128,
                      height: 128,
                      animated: true,
                      isThumbnail: false,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    };

    return Scaffold(
      backgroundColor: theme.colorScheme.onInverseSurface,
      body: SizedBox(
        width: double.maxFinite,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              pinned: true,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              title: SizedBox(
                height: 42,
                child: TextField(
                  style: TextStyle(color: theme.colorScheme.dialogTextFieldTextColor, ),
                  autofocus: false,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: L10n.of(context).search,
                    hintStyle: TextStyle(color: theme.colorScheme.dialogTextFieldHintTextColor),
                    prefixIcon: Icon(
                      Icons.search_outlined,
                      color: theme.colorScheme.dialogTextFieldHintTextColor,
                    ),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), 
                      borderSide: BorderSide(
                        color: theme.colorScheme.emojisAndStickersBorderColor, 
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.emojisAndStickersBorderColor, 
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.emojisAndStickersBorderColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (s) => setState(() => searchFilter = s),
                ),
              ),
            ),

            if (packSlugs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        L10n.of(context).noEmotesFound,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.oopsMessageTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => UrlLauncher(
                          context,
                          'https://matrix.to/#/#fluffychat-stickers:janian.de',
                        ).launchUrl(),
                        icon: Icon(Icons.explore_outlined,
                        color: theme.colorScheme.emojiIconTextColor,),
                        label: Text(L10n.of(context).discover,
                        style: TextStyle(color: theme.colorScheme.emojiIconTextColor,),),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  packBuilder,
                  childCount: packSlugs.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
