import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluffychat/pages/lives_data.dart';
import 'package:fluffychat/widgets/vods/vod_player.dart';
import 'package:fluffychat/widgets/vods/vods_widget.dart';

class ScreenVod extends StatefulWidget {
  final LiveShow? live;
  final String? liveId;

  const ScreenVod({
    this.live,
    this.liveId,
    super.key,
  });

  @override
  State<ScreenVod> createState() => _ScreenVodState();
}

class _ScreenVodState extends State<ScreenVod> {
  LiveShow? _live;
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _live = widget.live;

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
                          icon: const Icon(Icons.arrow_back),
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
                      const VodsWidget(
                        numColumns: 2,
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
                                    icon: const Icon(Icons.arrow_back),
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
                            flex: 3,
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
                          const Expanded(
                            flex: 1,
                            child: Column(
                              children: const [
                                SizedBox(height: 10),
                                VodsWidget(
                                  numColumns: 1,
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
