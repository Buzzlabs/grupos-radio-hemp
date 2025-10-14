import 'package:flutter/material.dart';
import 'package:fluffychat/widgets/streams_widget.dart';
import 'package:fluffychat/config/themes.dart';

class VideoPlayer extends StatefulWidget {
  final LiveShow live;

  const VideoPlayer({
    required this.live,
    super.key,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
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
        ],
      ),
    );
  }
}
