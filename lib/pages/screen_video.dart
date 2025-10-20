import 'package:flutter/material.dart';
import 'package:fluffychat/widgets/video_player_view.dart';
import 'package:fluffychat/widgets/streams_widget.dart';
import 'package:matrix/matrix.dart';
import 'package:go_router/go_router.dart';
import 'package:fluffychat/pages/lives_data.dart';

class ScreenVideo extends StatelessWidget {
  final LiveShow live;

  const ScreenVideo({
    required this.live,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobileMode = screenWidth < 1200;

            if (isMobileMode) {
              // === Layout para MOBILE ===
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Botão de voltar
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8),
                      child: Builder(
                        builder: (context) {
                          return IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              context
                                  .go('/rooms'); // funciona corretamente agora
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),
                    VideoPlayerWidget(live: live),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StreamsWidget(
                        numColumns: 2,
                        initialVisibleCount: 4,
                        loadMoreCount: 2,
                        showHeader: false,
                        enforceMobileMode: true,
                        streamsWidgetTag: '🔥 Destaques',
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // === Layout para DESKTOP  ===
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 45),
                              VideoPlayerWidget(live: live),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Builder(
                            builder: (context) {
                              return IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  context.go('/rooms'); // também funciona
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamsWidget(
                              numColumns: 1,
                              initialVisibleCount: 3,
                              loadMoreCount: 3,
                              showHeader: false,
                              enforceMobileMode: false,
                              streamsWidgetTag: '🔥 Destaques',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
