import 'package:flutter/material.dart';
import 'package:fluffychat/widgets/vods/live_card.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:fluffychat/pages/lives_data.dart';

class VodsWidget extends StatefulWidget {
  final String streamsWidgetTag;
  final VoidCallback? onShowMorePressed;
  final VoidCallback? onBackPressed;
  final String filter;

  final bool isAdmin;
  final int numColumns;
  final int initialVisibleCount;
  final int loadMoreCount;
  final bool enforceMobileMode;
  final bool showHeader;

  const VodsWidget({
    this.filter = '',
    required this.streamsWidgetTag,
    this.numColumns = 3,
    this.initialVisibleCount = 3,
    this.loadMoreCount = 3,
    this.enforceMobileMode = false,
    this.showHeader = true,
    this.onShowMorePressed,
    this.onBackPressed,
    this.isAdmin = false,
    super.key,
  });

  @override
  State<VodsWidget> createState() => _VodsWidgetState();
}

class _VodsWidgetState extends State<VodsWidget> {
  List<LiveShow> filteredLives = [];
  late int visibleCount;
  bool isLoading = false;

  int loadedCount = 0;
  int currentPage = 1;
  int lastPage = 1;
  int limit = 5; 

  @override
  void initState() {
    super.initState();
    visibleCount = widget.initialVisibleCount;
    limit = widget.initialVisibleCount;
    _fetchLives(); 
  }

  Future<void> _fetchLives({bool append = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final baseUrl = 'http://localhost:3333';
    final url = Uri.parse(
        '$baseUrl/dashboard/api/streams/vods?page=$currentPage&limit=10');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      final decoded = jsonDecode(response.body);

      final meta = decoded['meta'];
      lastPage = meta['last_page'];

      final List<dynamic> data = decoded['data'];
      final List<LiveShow> fetchedLives = data.map<LiveShow>((item) {
        final map = item as Map<String, dynamic>;

         String title = map['title'] ?? 'Sem título';

         final startedAtRaw = map['recordingStartedAt'];
         DateTime? startedAt;

         if (startedAtRaw != null) {
          startedAt = DateTime.tryParse(startedAtRaw);
        }
        
        if (title == 'Main Channel' && startedAt != null) {
          final formatted =
              '${startedAt.day.toString().padLeft(2, '0')}/${startedAt.month.toString().padLeft(2, '0')}/${startedAt.year.toString().substring(2)}';

          title = 'Live $formatted';
        }

        return LiveShow(
          id: map['id'].toString(),
          title: title,
          category: map['isLive'] == true ? 'Ao vivo' : 'Gravação',
          date: map['recordedRelativeTime'] ?? '',
          startedAt: map['recordingStartedAt'] ?? '',
          thumbnailUrl: map['latestThumbnail'] ?? '',
          avatarUrl: map['avatarUrl'] ?? 'assets/logo_single_comfundo.png',
          videoUrl: map['masterPlaylistUrl'] ?? '',
          isLive: map['isLive'] ?? false,
        );
      }).toList();

      if (append) {
        allLives.addAll(fetchedLives);
      } else {
        allLives = fetchedLives;
      }

      loadedCount = allLives.length;

      setState(() {
        _applyFilter();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _applyFilter() {
    filteredLives = allLives
        .where((live) =>
            live.title.toLowerCase().contains(widget.filter.toLowerCase()))
        .toList();
  }

  void _showMore() {
    final remainingVisible = loadedCount - visibleCount;

    if (remainingVisible >= widget.loadMoreCount) {
      setState(() => visibleCount += widget.loadMoreCount);
    } else if (currentPage < lastPage) {
      currentPage++;
      _fetchLives(append: true).then((_) {
        setState(() {
          visibleCount += widget.loadMoreCount;
          if (visibleCount > allLives.length) visibleCount = allLives.length;
        });
      });
    } else {
      setState(() => visibleCount = allLives.length);
    }
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
              Row(
                children: [
                  const SizedBox(width: 24),
                  Text(
                    widget.streamsWidgetTag,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ],
              ),
              if (visibleCount > widget.initialVisibleCount)
                Row(
                  children: [
                    const SizedBox(width: 24),
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () {
                        setState(() {
                          currentPage = 1; 
                          visibleCount = widget.initialVisibleCount;
                          allLives.clear(); 
                        });

                        _fetchLives(); 
                        widget.onBackPressed?.call();
                      },
                      child: const Text('< Voltar',
                          style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
            ],
          ),
        if (allLives.isEmpty)
          const Center(child: Text('Nenhum vod encontrado'))
        else if (filteredLives.isEmpty)
          const Center(child: Text('Nenhum vod encontrado'))
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              // to do
              // final isMobileMode =
              //     widget.enforceMobileMode || screenWidth < 1200;

              const spacing = 16.0;
              const horizontalPadding = 16.0;

              const minCardWidth = 250.0;

              int columns = (screenWidth / (minCardWidth + spacing)).floor();
              if (columns < 1) columns = 1;

              final totalSpacing =
                  (columns - 1) * spacing + horizontalPadding * 2;
              final itemWidth = (screenWidth - totalSpacing) / columns;

              double cardAspectRatio;

              if ((screenWidth / (minCardWidth + spacing)) >= 1.5 &&
                  (screenWidth / (minCardWidth + spacing)) < 2) {
                cardAspectRatio = 4 / 3.4; 
              } else if ((screenWidth / (minCardWidth + spacing)) < 1.5) {
                cardAspectRatio = 4 / 3.6; 
              }
              else if ((screenWidth / (minCardWidth + spacing)) >= 2.8 &&
                  (screenWidth / (minCardWidth + spacing)) <= 3) {
                cardAspectRatio = 4 / 3.5;
              } else if ((screenWidth / (minCardWidth + spacing)) >= 2.5 &&
                  (screenWidth / (minCardWidth + spacing)) <= 2.8) {
                cardAspectRatio = 4 / 3.78; 
              } else if ((screenWidth / (minCardWidth + spacing)) >= 2 &&
                  (screenWidth / (minCardWidth + spacing)) < 2.5) {
                cardAspectRatio = 4 / 3.95; 
              } else {
                cardAspectRatio = 1; 
              }
              final itemHeight = itemWidth / cardAspectRatio;
              final wrapWidth = columns * itemWidth + (columns - 1) * spacing;

              return Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: wrapWidth < screenWidth ? wrapWidth : screenWidth,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: spacing,
                    runSpacing: spacing,
                    children: visibleLives.map((live) {
                      return SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: LiveCard(live: live),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        if (visibleCount < loadedCount ||
            currentPage <
                lastPage) 
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color:
                        theme.colorScheme.onSecondaryContainer.withOpacity(0.2),
                  ),
                ),
                TextButton(
                  onPressed: _showMore,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    color:
                        theme.colorScheme.onSecondaryContainer.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
