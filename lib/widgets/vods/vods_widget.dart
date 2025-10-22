// streams_widget.dart
import 'package:flutter/material.dart';
import 'package:fluffychat/widgets/vods/live_card.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:fluffychat/pages/lives_data.dart';
import 'package:path/path.dart'; // lista global de LiveShow

class StreamsWidget extends StatefulWidget {
  final String streamsWidgetTag;
  final VoidCallback? onShowMorePressed;
  final VoidCallback? onBackPressed;
  final String filter;

  final int numColumns;
  final int initialVisibleCount;
  final int loadMoreCount;
  final bool enforceMobileMode;
  final bool showHeader;

  const StreamsWidget({
    this.filter = '',
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
  State<StreamsWidget> createState() => _StreamsWidgetState();
}

class _StreamsWidgetState extends State<StreamsWidget> {
  List<LiveShow> filteredLives = [];
  late int visibleCount;

  @override
  void initState() {
    super.initState();
    visibleCount = widget.initialVisibleCount;
    _fetchLives();
  }
  // varios live cards para teste
  // Future<void> _fetchLives() async {
  //   for (int i = 0; i < 5; i++) {
  //     allLives.add(LiveShow(
  //       id: 'id_$i',
  //       title: 'Live Show $i',
  //       category: 'Categoria $i',
  //       date: 'Data $i',
  //       thumbnailUrl: "https://vod.radiohemp.com/ivs/v1/324037287349/Owua07eBFR2k/2025/9/14/17/40/jUsmHY0dAIrr/media/thumbnails/thumb120.jpg",
  //       avatarUrl: 'https://via.placeholder.com/50',
  //       videoUrl: 'https://www.example.com/video$i',
  //       isLive: i % 2 == 0,
  //     ));

  //     filteredLives = allLives;
  //   }
  // }

  Future<void> _fetchLives() async {
    final baseUrl = 'http://localhost:3333';
    final url = Uri.parse('$baseUrl/dashboard/api/streams');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('Resposta inesperada: esperava um array JSON');
      }

      final List<LiveShow> fetchedLives = decoded.map<LiveShow>((dynamic item) {
        final map = item as Map<String, dynamic>;
        return LiveShow(
          id: (map['id']?.toString() ?? 'id'),
          title: map['title'] as String? ?? 'Sem título',
          category: (map['isLive'] == true) ? 'Ao vivo' : 'Gravação', // alterar
          date: map['recordedRelativeTime'] as String? ?? '',
          thumbnailUrl: map['latestThumbnail'] as String? ?? '',
          avatarUrl:
              map['avatarUrl'] as String? ?? 'assets/logo_single_comfundo.png',
          videoUrl: map['masterPlaylistUrl'] as String? ?? '',
          isLive: map['isLive'] as bool? ?? false,
        );
      }).toList();

      // Atualiza a lista global
      allLives = fetchedLives;

      if (!equals(widget.filter, "")) return;
      setState(() {
        _applyFilter();
      });
    } on TimeoutException catch (_) {
      debugPrint('Requisição expirou');
    } catch (e, st) {
      debugPrint('Erro ao buscar lives: $e\n$st');
    }
  }

  void _applyFilter() {
    filteredLives = allLives
        .where((live) =>
            live.title.toLowerCase().contains(widget.filter.toLowerCase()))
        .toList();
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
        if (allLives.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (filteredLives.isEmpty)
          const Center(child: Text('Nenhuma live encontrada'))
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
                    children: visibleLives
                        .map((live) => SizedBox(
                              width: itemWidth,
                              child: LiveCard(live: live),
                            ))
                        .toList(),
                  );
                },
              ),
              if (widget.showHeader && visibleCount < filteredLives.length)
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
                              horizontal: 12, vertical: 4),
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
