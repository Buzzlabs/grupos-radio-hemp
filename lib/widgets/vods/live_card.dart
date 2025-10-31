import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fluffychat/pages/lives_data.dart';
import 'package:flutter/services.dart';
import 'package:fluffychat/widgets/streaming/audio_player_streaming.dart';

class LiveCard extends StatelessWidget {
  final LiveShow live;

  const LiveCard({required this.live, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      final double cardWidth = constraints.maxWidth.clamp(200, 350);

      return Container(
        width: cardWidth,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              AudioState.mutedNotifier.value = true;

              final roomId = GoRouterState.of(context).pathParameters['roomid'];
              if (roomId != null) {
                context.go('/rooms/$roomId/vod/${live.id}');
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === THUMBNAIL COM ASPECT RATIO ===
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10), // define o arredondado
                      child: AspectRatio(
                        aspectRatio: 16 / 9, // mantém proporção fixa
                        child: Image.network(
                          live.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 80),
                        ),
                      ),
                    ),
                    if (live.isLive)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'AO VIVO',
                            style: GoogleFonts.righteous(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // === AVATAR + TÍTULO + INFO ===
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(live.avatarUrl),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            live.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _infoChip(
                                  theme,
                                  live.date,
                                  theme.colorScheme.onSecondaryContainer
                                      .withOpacity(0.15),
                                  13),
                              // _infoChip(
                              //     theme,
                              //     live.category,
                              //     theme.colorScheme.primary.withOpacity(0.15),
                              //     12),
                            ],
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            final roomId = GoRouterState.of(context)
                                .pathParameters['roomid'];
                            final shareLink =
                                'https://localhost//rooms/$roomId/vod/${live.id}';
                            Clipboard.setData(ClipboardData(text: shareLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copiado!')),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.share,
                              size: 18,
                              color: theme.colorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _infoChip(ThemeData theme, String text, Color bg, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: theme.colorScheme.onSecondary,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
