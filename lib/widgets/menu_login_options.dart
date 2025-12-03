import 'package:fluffychat/config/themes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MoreLoginMenuButton extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const MoreLoginMenuButton({
    super.key,
    required this.padding,
  });

  Future<void> _handleAction(
      BuildContext context, MoreLoginActions action,) async {
    switch (action) {
      case MoreLoginActions.about:
        PlatformInfos.showAboutInfo(context);
        break;

      case MoreLoginActions.store:
        await launchUrl(
          Uri.parse('https://www.radiohemp.com/store/'),
          mode: LaunchMode.externalApplication,
        );
        break;

      case MoreLoginActions.course:
        await launchUrl(
          Uri.parse(
            'https://pp.nexojornal.com.br/',
          ),
          mode: LaunchMode.externalApplication,
        );
        break;

      case MoreLoginActions.podcasts:
        await launchUrl(
          Uri.parse('https://www.radiohemp.com/podcast/'),
          mode: LaunchMode.externalApplication,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: PopupMenuButton<MoreLoginActions>(
        color: theme.colorScheme.tertiary,
        onSelected: (action) => _handleAction(context, action),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: MoreLoginActions.store,
            child: Row(
              children: [
                Icon(
                Icons.shopping_cart,
                color: theme.colorScheme.loginMenuIconColor,
                size: 20,
              ),
                // SvgPicture.asset(
                //   'assets/icons/store.svg',
                //   width: 30,
                // ),
                const SizedBox(width: 18),
                Text(L10n.of(context).menuStore, style: TextStyle(color: theme.colorScheme.loginMenuTextColor),
),
              ],
            ),
          ),
          PopupMenuItem(
            value: MoreLoginActions.course,
            child: Row(
              children: [
                Icon(
                Icons.book,
                color: theme.colorScheme.loginMenuIconColor,
                size: 20,
              ),
                // SvgPicture.asset(
                //   'assets/icons/course.svg',
                //   width: 30,
                // ),
                const SizedBox(width: 18),
                Text(L10n.of(context).menuCourse, style: TextStyle(color: theme.colorScheme.loginMenuTextColor),
),
              ],
            ),
          ),
          PopupMenuItem(
            value: MoreLoginActions.podcasts,
            child: Row(
              children: [
                 Icon(
                Icons.mic,
                color: theme.colorScheme.loginMenuIconColor,
                size: 20,
              ),
                // SvgPicture.asset(
                //   'assets/icons/podcast.svg',
                //   width: 30,
                // ),
                const SizedBox(width: 18),
                Text(L10n.of(context).menuPodcasts, style: TextStyle(color: theme.colorScheme.loginMenuTextColor),
),
              ],
            ),
          ),
          PopupMenuItem(
            value: MoreLoginActions.about,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(
                    Icons.info_outlined,
                    color: Theme.of(context).colorScheme.loginMenuIconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(L10n.of(context).about,style: TextStyle(color: theme.colorScheme.loginMenuTextColor),
),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum MoreLoginActions {
  store,
  course,
  podcasts,
  about,
}
