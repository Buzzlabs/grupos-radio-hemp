import 'package:flutter/material.dart';
import 'package:fluffychat/widgets/vods/live_card.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:fluffychat/pages/lives_data.dart';
import 'package:path/path.dart'; // lista global de LiveShow

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
  int limit = 5; // quantos carregar a cada fetch
  // int totalFakeLives = 30; // total de lives fake

  @override
  void initState() {
    super.initState();
    visibleCount = widget.initialVisibleCount;
    limit = widget.initialVisibleCount;
    // _fetchFakeLives(); // função teste
    _fetchLives(); // função real do backend
  }

// // varios live cards para teste
// Future<void> _fetchFakeLives({bool append = false}) async {
//     if (isLoading) return;
//     setState(() => isLoading = true);

//     await Future.delayed(const Duration(milliseconds: 300)); // simula requisição

//     final start = (currentPage - 1) * limit;
//     final end = (start + limit).clamp(0, totalFakeLives);

//     final newLives = List.generate(end - start, (i) {
//       final index = start + i;
//       return LiveShow(
//         id: 'id_$index',
//         title: 'Live Show $index',
//         category: 'Categoria $index',
//         date: 'Data $index',
//         thumbnailUrl:
//             "https://vod.radiohemp.com/ivs/v1/324037287349/Owua07eBFR2k/2025/9/14/17/40/jUsmHY0dAIrr/media/thumbnails/thumb120.jpg",
//         avatarUrl: 'assets/logo_single_comfundo.png',
//         videoUrl:
//             'https://vod.radiohemp.com/ivs/v1/324037287349/Owua07eBFR2k/2025/9/14/17/40/jUsmHY0dAIrr/media/hls/master.m3u8',
//         isLive: false,
//       );
//     });

//     if (append) {
//       allLives.addAll(newLives);
//     } else {
//       allLives = newLives;
//     }

//     filteredLives = allLives;

//     setState(() {
//       isLoading = false;
//     });
//   }

  Future<void> _fetchLives({bool append = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final baseUrl = 'http://localhost:3333';
    final url =
        Uri.parse('$baseUrl/dashboard/api/streams/vods?page=$currentPage&limit=10');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      final decoded = jsonDecode(response.body);

      // extrai meta do backend
      final meta = decoded['meta'];
      lastPage = meta['last_page'];

      // extrai lista de streams
      final List<dynamic> data = decoded['data'];
      final List<LiveShow> fetchedLives = data.map<LiveShow>((item) {
        final map = item as Map<String, dynamic>;
        return LiveShow(
          id: map['id'].toString(),
          title: map['title'] ?? 'Sem título',
          category: map['isLive'] == true ? 'Ao vivo' : 'Gravação',
          date: map['recordedRelativeTime'] ?? '',
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
    // já temos items carregados suficientes → só aumenta visibleCount
    setState(() => visibleCount += widget.loadMoreCount);
  } else if (currentPage < lastPage) {
    // precisamos buscar mais do backend
    currentPage++;
    _fetchLives(append: true).then((_) {
      setState(() {
        // sempre mostra apenas 5 a mais
        visibleCount += widget.loadMoreCount;
        if (visibleCount > allLives.length) visibleCount = allLives.length;
      });
    });
  } else {
    // última página → mostra tudo que restou
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
                          currentPage = 1;          // 🔥 reset
                          visibleCount = widget.initialVisibleCount;
                          allLives.clear();         // 🔥 limpa lives carregadas
                        });

                        _fetchLives();              // 🔥 carrega página 1 novamente
                        widget.onBackPressed?.call();
                      },

                      child: const Text('< Voltar',
                          style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              // const SizedBox(height: 24),
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
              final isMobileMode =
                  widget.enforceMobileMode || screenWidth < 1200;

              const spacing = 16.0;
              const horizontalPadding = 16.0;

              // largura mínima do card
              const minCardWidth = 250.0;

              // calcula o número máximo de colunas que cabem
              int columns = (screenWidth / (minCardWidth + spacing)).floor();
              if (columns < 1) columns = 1;

              // largura de cada card mantendo o spacing fixo
              final totalSpacing =
                  (columns - 1) * spacing + horizontalPadding * 2;
              final itemWidth = (screenWidth - totalSpacing) / columns;

              // proporção do LiveCard (largura/altura estimada)
              double cardAspectRatio;

              // para colum = 1
              if ((screenWidth / (minCardWidth + spacing)) >= 1.5 &&
                  (screenWidth / (minCardWidth + spacing)) < 2) {
                cardAspectRatio = 4 / 3.4; // mais achatado pra 1 coluna
              } else if ((screenWidth / (minCardWidth + spacing)) < 1.5) {
                cardAspectRatio = 4 / 3.6; // um pouco mais alto
              }
              // para colum = 2
              else if ((screenWidth / (minCardWidth + spacing)) >= 2.8 &&
                  (screenWidth / (minCardWidth + spacing)) <= 3) {
                cardAspectRatio = 4 / 3.5;
              } else if ((screenWidth / (minCardWidth + spacing)) >= 2.5 &&
                  (screenWidth / (minCardWidth + spacing)) <= 2.8) {
                cardAspectRatio = 4 / 3.78; // um pouco mais alto
              } else if ((screenWidth / (minCardWidth + spacing)) >= 2 &&
                  (screenWidth / (minCardWidth + spacing)) < 2.5) {
                cardAspectRatio = 4 / 3.95; // um pouco mais alto
                // para colum = 3
              } else {
                cardAspectRatio = 1; // padrão 1:1
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
        if (visibleCount < loadedCount || currentPage < lastPage) // if ((currentPage * limit) < totalFakeLives)
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
