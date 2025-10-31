import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class VodPlayerView extends StatelessWidget {
  final dynamic controller;
  final String title;
  final String avatarUrl;
  final String playbackUrl;
  final String date;
  final String category;
  final String viewId;
  final String id;
  final bool isAdmin;
  final bool isPreview;
  final VoidCallback onClose;
  final VoidCallback onEdit;

  const VodPlayerView(
    this.controller, {
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.playbackUrl,
    required this.viewId,
    required this.date,
    required this.category,
    required this.id,
    required this.isAdmin,
    required this.isPreview,
    required this.onClose,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1200;
    final videoWidth = isMobile ? screenWidth : screenWidth * 0.7;
    final videoHeight = videoWidth / (16 / 9);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: videoWidth,
              height: videoHeight,
              child: HtmlElementView(viewType: viewId),
            ),
          ),
          const SizedBox(height: 12),

          // Info tipo YouTube
          SizedBox(
            width: videoWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(avatarUrl),
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSecondaryContainer
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      date,
                      style: TextStyle(
                        color: theme.colorScheme.onSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Container(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  //   decoration: BoxDecoration(
                  //     color: theme.colorScheme.primary.withOpacity(0.15),
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: Text(
                  //     category,
                  //     style: TextStyle(
                  //       color: theme.colorScheme.onSecondary,
                  //       fontSize: 12,
                  //     ),
                  //   ),
                  // ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      final roomId =
                          GoRouterState.of(context).pathParameters['roomid'];

                      final shareLink =
                          'https://localhost//rooms/$roomId/screen_vod/${id}';
                      Clipboard.setData(ClipboardData(text: shareLink));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copiado!')),
                      );
                    },
                    icon: Icon(
                      Icons.share,
                      size: 18,
                      color: theme.colorScheme.onSecondary,
                    ),
                  )
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
