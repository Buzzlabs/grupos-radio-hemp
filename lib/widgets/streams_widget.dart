import 'package:flutter/material.dart';
import 'package:fluffychat/widgets/live_card.dart';
import 'package:fluffychat/config/themes.dart';

// Modelo de dados da Live
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
  const StreamsWidget({super.key});

  @override
  State<StreamsWidget> createState() => _StreamsWidget();
}

class _StreamsWidget extends State<StreamsWidget> {
  // classe privada que gerencia o estado
  List<LiveShow> lives = [];
  int visibleCount = 3;

  @override
  void initState() {
    // inicializa
    super.initState();
    _fetchLives();
  }

  // Simula busca de lives (substitua por chamada de API)
  Future<void> _fetchLives() async {
    await Future.delayed(const Duration(seconds: 1)); // simula carregamento
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
    ];

    setState(() {
      lives = fetchedLives;
    });
  }

  void _showMore() {
    setState(() {
      visibleCount += 3;
    });
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleLives = lives.take(visibleCount).toList();

    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔥 Destaques',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.w100,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 24),
            // Se estiver carregando:
            if (lives.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              // Grade de cards
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // GridView vem com scroll
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // num de colunas
                  mainAxisSpacing: 16, // espaço vertical
                  crossAxisSpacing: 16, // espaço horizontal
                  childAspectRatio: 1.2, // proporção dos cards
                ),
                itemCount: visibleLives.length,
                itemBuilder: (context, index) {
                  return LiveCard(live: visibleLives[index]);
                },
              ),

            const SizedBox(height: 10),

            // Botão "Mostrar mais"
            if (visibleCount < lives.length)
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Linha antes
                    Expanded(
                      child: SizedBox(
                        child: Divider(
                          color: theme.colorScheme.primary,
                          thickness: 1,
                          endIndent: 8,
                        ),
                      ),
                    ),
                    // Texto clicável
                    TextButton(
                      onPressed: _showMore,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // remove espaço extra
                        minimumSize:
                            const Size(0, 0), // evita botão muito grande
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap, // área justa
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
                    // Linha depois
                    Expanded(
                      child: SizedBox(
                        child: Divider(
                          color: theme.colorScheme.primary,
                          thickness: 1,
                          indent: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
