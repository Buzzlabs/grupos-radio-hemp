import 'package:flutter/material.dart';
import 'package:fluffychat/widgets/live_card.dart';
import 'package:fluffychat/config/themes.dart';

class LiveShow {
  final String title;
  final String category;
  final String date;
  final String thumbnailUrl;
  final String avatarUrl;
  final bool isLive;

  LiveShow({
    required this.title,
    required this.category,
    required this.date,
    required this.thumbnailUrl,
    required this.avatarUrl,
    this.isLive = false,
  });
}

class StreamsWidget extends StatefulWidget {
  final String streamsWidgetTag;
  final VoidCallback? onShowMorePressed;
  final VoidCallback? onBackPressed;
  final int numLivesShowing;

  const StreamsWidget({
    required this.streamsWidgetTag,
    required this.numLivesShowing,
    this.onShowMorePressed,
    this.onBackPressed,
    super.key,
  });

  @override
  State<StreamsWidget> createState() => _StreamsWidget();
}

class _StreamsWidget extends State<StreamsWidget> {
  List<LiveShow> lives = [];
  late int visibleCount;

  @override
  void initState() {
    super.initState();
    visibleCount = widget.numLivesShowing;
    _fetchLives();
  }

  Future<void> _fetchLives() async {
    await Future.delayed(const Duration(seconds: 1));
    final fetchedLives = [
      LiveShow(
        title: 'Título da Live 1',
        category: 'Música',
        date: '17 de Junho',
        thumbnailUrl: 'assets/images/live_thumbnail.jpg',
        avatarUrl: 'assets/images/live_avatar.jpg',
        isLive: true,
      ),
      LiveShow(
        title: 'Título da Live 2',
        category: 'Podcast',
        date: '15 de Junho',
        thumbnailUrl: 'assets/images/live_thumbnail.jpg',
        avatarUrl: 'assets/images/live_avatar.jpg',
      ),
      LiveShow(
        title: 'Título da Live 3',
        category: 'Cultura',
        date: '12 de Junho',
        thumbnailUrl: 'assets/images/live_thumbnail.jpg',
        avatarUrl: 'assets/images/live_avatar.jpg',
      ),
      LiveShow(
        title: 'Título da Live 4',
        category: 'Música',
        date: '10 de Junho',
        thumbnailUrl: 'assets/images/live_thumbnail.jpg',
        avatarUrl: 'assets/images/live_avatar.jpg',
      ),
      LiveShow(
        title: 'Título da Live 5',
        category: 'Música',
        date: '9 de Junho',
        thumbnailUrl: 'assets/images/live_thumbnail.jpg',
        avatarUrl: 'assets/images/live_avatar.jpg',
      ),
      LiveShow(
        title: 'Título da Live 6',
        category: 'Música',
        date: '10 de Junho',
        thumbnailUrl: 'assets/images/live_thumbnail.jpg',
        avatarUrl: 'assets/images/live_avatar.jpg',
      ),
      LiveShow(
        title: 'Título da Live 7',
        category: 'Música',
        date: '10 de Junho',
        thumbnailUrl: 'assets/images/live_thumbnail.jpg',
        avatarUrl: 'assets/images/live_avatar.jpg',
      ),
    ];

    setState(() {
      lives = fetchedLives;
    });
  }

  void _showMore() {
    setState(() {
      visibleCount += widget.numLivesShowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleLives = lives.take(visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== Cabeçalho com título + botão voltar (quando expandido) =====
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
            if (visibleCount >
                widget.numLivesShowing) // se mostrar mais foi clicado
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  setState(() => visibleCount = widget.numLivesShowing);
                  widget.onBackPressed?.call(); // <<==== avisa o pai
                },
                child: const Text(
                  '< Voltar',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 24),

        // ===== Conteúdo =====
        if (lives.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.numLivesShowing,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: visibleLives.length,
            itemBuilder: (context, index) {
              return LiveCard(live: visibleLives[index]);
            },
          ),

        const SizedBox(height: 10),

        // ===== Botão Mostrar mais =====
        // Botão "Mostrar mais"
        if (visibleCount < lives.length)
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.primary,
                    thickness: 1,
                    endIndent: 8,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showMore();
                    widget.onShowMorePressed?.call(); // <<==== avisa o pai
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
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
                  child: Divider(
                    color: theme.colorScheme.primary,
                    thickness: 1,
                    indent: 8,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
