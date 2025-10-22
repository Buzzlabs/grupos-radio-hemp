import 'package:flutter/material.dart';

class VodPlayerView extends StatelessWidget {
  final dynamic controller;
  final String title;
  final String avatarUrl;
  final String playbackUrl;
  final String viewId;
  final bool isAdmin;
  final bool isPreview;
  final VoidCallback onClose;
  final VoidCallback onEdit;

  const VodPlayerView(
    this.controller, {
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.playbackUrl,
    required this.viewId,
    required this.isAdmin,
    required this.isPreview,
    required this.onClose,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final aspectRatio = 16 / 9;
    final videoWidth = screenWidth * 0.7;
    final videoHeight = videoWidth / aspectRatio;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: videoWidth,
              height: videoHeight,
              child: HtmlElementView(viewType: viewId),
            ),
          ),
          const SizedBox(height: 12),

          // Info tipo YouTube
          Row(
            children: [
               CircleAvatar(
                radius: 15,
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(avatarUrl),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
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
