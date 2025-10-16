import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/widgets/streams_widget.dart';
import 'package:fluffychat/pages/lives_data.dart';
import 'package:flutter/services.dart';

class VideoPlayerWidget extends StatefulWidget {
  final LiveShow live;

  const VideoPlayerWidget({required this.live, super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.live.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    children: [
                      VideoPlayer(_controller),
                      // Botão play/pause opcional
                      Positioned.fill(
                        child: Center(
                          child: IconButton(
                            iconSize: 64,
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(
                  widget.live.avatarUrl.isNotEmpty
                      ? widget.live.avatarUrl
                      : 'https://via.placeholder.com/150',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.live.title,
                  style: TextStyle(
                    color: theme.colorScheme.onSecondary,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSecondaryContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.live.date,
                  style: TextStyle(
                    color: theme.colorScheme.onSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  final shareLink =
                      'https://localhost/screen_video/${widget.live.id}';
                  Clipboard.setData(ClipboardData(text: shareLink));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copiado!')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.share,
                    size: 18,
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
