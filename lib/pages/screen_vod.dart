import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluffychat/pages/lives_data.dart';
import 'package:fluffychat/widgets/vods/vod_player.dart';

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
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8),
                        child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              final router = GoRouter.of(context);
                              if (router.canPop()) {
                                router.pop();
                              } else {
                                router.go('/rooms');
                              }
                            }),
                      ),
                      const SizedBox(height: 8),
                      VodPlayer(
                        avatarUrl: _live!.avatarUrl,
                        playbackUrl: _live!.videoUrl,
                        title: _live!.title,
                        isAdmin: false,
                        date: _live!.date,
                        category: _live!.category,
                        id: _live!.id,
                      ),
                      // to do
                      // const Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: VodsWidget(
                      //     numColumns: 2,
                      //     initialVisibleCount: 4,
                      //     loadMoreCount: 2,
                      //     showHeader: false,
                      //     enforceMobileMode: true,
                      //     streamsWidgetTag: '🔥 Destaques',
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            } else {
              return Scaffold(
                body: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                        return Stack(
                          children: [
                            Center(
                              child: VodPlayer(
                                avatarUrl: _live!.avatarUrl,
                                playbackUrl: _live!.videoUrl,
                                title: _live!.title,
                                isAdmin: false,
                                date: _live!.date,
                                category: _live!.category,
                                id: _live!.id,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 8,
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
                          ],
                        );
                      
                    },
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
