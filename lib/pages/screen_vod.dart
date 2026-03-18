import 'package:fluffychat/config/themes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluffychat/pages/lives_data.dart';
import 'package:fluffychat/widgets/vods/vod_player.dart';
import 'package:fluffychat/widgets/vods/vods_widget.dart';

class ScreenVod extends StatefulWidget {
  final String? liveId;

  ScreenVod({
    Key? key,
    this.liveId,
  }) : super(key: ValueKey(liveId));

  @override
  State<ScreenVod> createState() => _ScreenVodState();
}

class _ScreenVodState extends State<ScreenVod> {
  LiveShow? _live;
  bool _loading = false;
  bool _error = false;

  @override
  void didUpdateWidget(covariant ScreenVod oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.liveId != widget.liveId) {
      _live = null;
      _fetchLive(widget.liveId!);
    }
  }

  @override
  void initState() {
    super.initState();

    if (_live == null && widget.liveId != null) {
      _fetchLive(widget.liveId!);
    }
  }

  Future<void> _fetchLive(String id) async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final fetched = await fetchLiveById(id);
      if (mounted) {
        setState(() {
          _live = fetched;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) { 
    final theme = Theme.of(context);
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error || _live == null) {
      return const Scaffold(
        body: Center(child: Text('Vod não encontrado')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobileMode = screenWidth < 1200;

            if (isMobileMode) {
              return Scaffold(
                body: SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Botão de voltar
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: theme.colorScheme.vodCardBackgroundColor,),
                          onPressed: () {
                            final router = GoRouter.of(context);
                            if (router.canPop()) {
                              router.pop();
                            } else {
                              router.go('/rooms');
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      // PLAYER
                      VodPlayer(
                        avatarUrl: _live!.avatarUrl,
                        playbackUrl: _live!.videoUrl,
                        title: _live!.title,
                        isAdmin: false,
                        date: _live!.date,
                        category: _live!.category,
                        id: _live!.id,
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // LISTA DE OUTROS VODs
                      VodsWidget(
                        numColumns: 2,
                        idCardOnShow: _live!.id,
                        initialVisibleCount: 6,
                        loadMoreCount: 2,
                        showHeader: false,
                        enforceMobileMode: true,
                        streamsWidgetTag: '',
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1600),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Positioned(
                            top: 8,
                            left: 0,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: theme.colorScheme.vodScreenBackButtonColor,),
                              onPressed: () {
                                final router = GoRouter.of(context);
                                if (router.canPop()) {
                                  router.pop();
                                } else {
                                  router.go('/rooms');
                                }
                              },
                            ),
                          ),

                          /// PLAYER (lado esquerdo)
                          Expanded(
                            flex: 5,
                            child: Stack(
                              children: [
                                VodPlayer(
                                  avatarUrl: _live!.avatarUrl,
                                  playbackUrl: _live!.videoUrl,
                                  title: _live!.title,
                                  isAdmin: false,
                                  date: _live!.date,
                                  category: _live!.category,
                                  id: _live!.id,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 32),

                          /// LISTA (lado direito)
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                VodsWidget(
                                  numColumns: 1,
                                  idCardOnShow: _live!.id,
                                  initialVisibleCount: 8,
                                  loadMoreCount: 4,
                                  showHeader: false,
                                  enforceMobileMode: false,
                                  streamsWidgetTag: '',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
