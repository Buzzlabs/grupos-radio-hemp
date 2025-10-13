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
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: Colors.black12,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  widget.live.avatarUrl.isNotEmpty
                      ? widget.live.avatarUrl
                      : 'https://via.placeholder.com/150',
                ),
                // remove onBackgroundImageError para ver se aparece o erro no console
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.live.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
