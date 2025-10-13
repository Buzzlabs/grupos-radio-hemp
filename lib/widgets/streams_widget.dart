import 'package:flutter/material.dart';
import 'package:fluffychat/widgets/live_card.dart';

class LiveShow {
  final String title;
  final String category;
  final String date;
  final String thumbnailUrl;
  final String videoUrl;
  final String avatarUrl;
  final bool isLive;

  LiveShow({
    required this.title,
    required this.category,
    required this.date,
    required this.thumbnailUrl,
    required this.avatarUrl,
    required this.videoUrl,
    this.isLive = false,
  });
}

class StreamsWidget extends StatefulWidget {
  final String streamsWidgetTag;
  final VoidCallback? onShowMorePressed;
  final VoidCallback? onBackPressed;

  final int numColumns;
  final int initialVisibleCount;
  final int loadMoreCount;
  final bool enforceMobileMode;
  final bool showHeader;

  const StreamsWidget({
    required this.streamsWidgetTag,
    this.numColumns = 3,
    this.initialVisibleCount = 3,
    this.loadMoreCount = 3,
    this.enforceMobileMode = false,
    this.showHeader = true,
    this.onShowMorePressed,
    this.onBackPressed,
    super.key,
  });

  @override
  State<StreamsWidget> createState() => _StreamsWidget();
}

class _StreamsWidget extends State<StreamsWidget> {
  List<LiveShow> allLives = [];
  List<LiveShow> filteredLives = [];
  late int visibleCount;

  @override
  void initState() {
    super.initState();
    visibleCount = widget.initialVisibleCount;
    _fetchLives();
  }

  Future<void> _fetchLives() async {
    await Future.delayed(const Duration(seconds: 1));
    final fetchedLives = [
      LiveShow(
        title: 'Amendoshow com Ygor Amendoim',
        category: 'Música',
        date: '17 de Julho',
        thumbnailUrl: 'assets/images_for_live_card/thumbnail_Amendoshow.png',
        avatarUrl: 'assets/logo_single_comfundo.png',
        videoUrl: '',
        isLive: false,
      ),
      LiveShow(
        title: 'THShow com Igor Seco e Nhock',
        category: 'Podcast',
        date: '17 de Julho',
        thumbnailUrl: 'assets/images_for_live_card/thumbnail_THShow.png',
        videoUrl: '',
        avatarUrl: 'assets/logo_single_comfundo.png',
      ),
      LiveShow(
        title: 'O Fino do Ronald com Ronald Rios',
        category: 'Música',
        date: '17 de Julho',
        thumbnailUrl: 'assets/images_for_live_card/thumbnail_FinoRonald.png',
        videoUrl: '',
        avatarUrl: 'assets/logo_single_comfundo.png',
      ),
      LiveShow(
        title: 'Amendoshow com Ygor Amendoim',
        category: 'Música',
        date: '10 de Julho',
        thumbnailUrl: 'assets/images_for_live_card/thumbnail_Amendoshow.png',
        videoUrl: '',
        avatarUrl: 'assets/logo_single_comfundo.png',
      ),
      LiveShow(
        title: 'THShow com Igor Seco e Nhock',
        category: 'Podcast',
        date: '9 de Julho',
        thumbnailUrl: 'assets/images_for_live_card/thumbnail_THShow.png',
        videoUrl: '',
        avatarUrl: 'assets/logo_single_comfundo.png',
      ),
      LiveShow(
        title: 'O Fino do Ronald com Ronald Rios',
        category: 'Música',
        date: '8 de Julho',
        thumbnailUrl: 'assets/images_for_live_card/thumbnail_FinoRonald.png',
        videoUrl: '',
        avatarUrl: 'assets/logo_single_comfundo.png',
      ),
      LiveShow(
        title: 'Amendoshow com Ygor Amendoim',
        category: 'Música',
        date: '8 de Julho',
        thumbnailUrl: 'assets/images_for_live_card/thumbnail_Amendoshow.png',
        videoUrl: '',
        avatarUrl: 'assets/logo_single_comfundo.png',
      ),
    ];

    setState(() {
      allLives = fetchedLives;
      _applyFilter();
    });
  }

  // === FILTRA POR TÓPICO ===
  void _applyFilter() {
    final tag = widget.streamsWidgetTag.trim();
    if (tag.contains('Destaques')) {
      filteredLives = allLives;
    } else if (tag.contains('Amendoshow')) {
      filteredLives = allLives
          .where((live) => live.title.toLowerCase().contains('amendoshow'))
          .toList();
    } else if (tag.contains('THShow')) {
      filteredLives = allLives
          .where((live) => live.title.toLowerCase().contains('thshow'))
          .toList();
    } else if (tag.contains('O Fino')) {
      filteredLives = allLives
          .where((live) => live.title.toLowerCase().contains('fino'))
          .toList();
    } else {
      filteredLives = allLives;
    }
  }

  void _showMore() {
    setState(() {
      visibleCount += widget.loadMoreCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleLives = filteredLives.take(visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.streamsWidgetTag,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                ),
              ),
              if (visibleCount > widget.initialVisibleCount)
                TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    setState(() => visibleCount = widget.initialVisibleCount);
                    widget.onBackPressed?.call();
                  },
                  child: const Text('< Voltar', style: TextStyle(fontSize: 14)),
                ),
              const SizedBox(height: 24),
            ],
          ),

        // === LIVE CARDS ===
        if (filteredLives.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else
          Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final isMobileMode =
                      widget.enforceMobileMode || screenWidth < 1200;

                  int columns = widget.numColumns;

                  if (isMobileMode && screenWidth < 500) {
                    columns = 1;
                  }

                  const spacing = 16.0;
                  const horizontalPadding = 32.0;
                  final totalSpacing = (columns - 1) * spacing;
                  final availableWidth =
                      screenWidth - totalSpacing - horizontalPadding;
                  final itemWidth =
                      (availableWidth / columns) - (isMobileMode ? 4 : 0);

                  return Wrap(
                    spacing: spacing,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: visibleLives.map((live) {
                      return SizedBox(
                        width: itemWidth,
                        child: LiveCard(live: live),
                      );
                    }).toList(),
                  );
                },
              ),

              // === botão MOSTRAR MAIS ===
              if (visibleCount < filteredLives.length)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: theme.colorScheme.onSecondaryContainer
                              .withOpacity(0.2),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showMore();
                          widget.onShowMorePressed?.call();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Mostrar mais >',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: theme.colorScheme.onSecondaryContainer
                              .withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
