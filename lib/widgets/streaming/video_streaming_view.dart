import 'package:flutter/material.dart';
import 'video_streaming.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/l10n/l10n.dart';

class VideoStreamingView extends StatefulWidget {
  final VideoStreamingController controller;
  final String title;
  final String playbackUrl;
  final String viewId;
  final bool isAdmin;
  final bool isPreview;
  final VoidCallback onClose;
  final VoidCallback onEdit;

  const VideoStreamingView(
    this.controller, {
    super.key,
    required this.title,
    required this.playbackUrl,
    required this.viewId,
    required this.isAdmin,
    required this.isPreview,
    required this.onClose,
    required this.onEdit,
  });

  @override
  State<VideoStreamingView> createState() => _VideoStreamingViewState();
}

class _VideoStreamingViewState extends State<VideoStreamingView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobileMode = !FluffyThemes.isColumnMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final defaultWidth = isMobileMode ? screenWidth * 0.9 : screenWidth * 0.3;
    widget.controller.initializeIfNeeded(defaultWidth);

    return ValueListenableBuilder<Offset>(
      valueListenable: widget.controller.positionNotifier,
      builder: (context, position, _) {
        return ValueListenableBuilder<double>(
          valueListenable: widget.controller.widthNotifier,
          builder: (context, width, __) {
            const aspectRatio = 16 / 9;
            final normalHeight = width / aspectRatio;

            final maxHeight = (isMobileMode &&
                    widget.controller.widget.isInputFocused == true)
                ? screenHeight * 0.25
                : normalHeight;

            final adjustedHeight = normalHeight.clamp(0, maxHeight);
            final adjustedWidth = adjustedHeight * aspectRatio;

            final boxHeight = adjustedHeight + 50;
            final fixedLeft = (screenWidth - adjustedWidth) / 2;

            final content = Material(
              color: Colors.transparent,
              child: Container(
                width: adjustedWidth,
                height: boxHeight.toDouble(),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.surface,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(adjustedWidth),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: HtmlElementView(viewType: widget.viewId),
                      ),
                    ),
                  ],
                ),
              ),
            );

            return widget.isPreview
                ? content
                : Positioned(
                    top: position.dy,
                    left: isMobileMode ? fixedLeft : position.dx,
                    child: content,
                  );
          },
        );
      },
    );
  }

  Widget _buildHeader(double width) {
    final socketClient = widget.controller.socketClient;

    return SizedBox(
      width: width,
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.red),
          const SizedBox(width: 6),

          // Título
          Expanded(
            child: Text(
              widget.title.isNotEmpty
                  ? '${(L10n.of(context).live).toUpperCase()} - ${widget.title}'
                  : (L10n.of(context).live).toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

          ValueListenableBuilder<int>(
            valueListenable: socketClient.liveViewers,
            builder: (context, viewers, _) {
              if (viewers <= 0) return const SizedBox.shrink();
              return Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    viewers.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              );
            },
          ),

          if (widget.isAdmin && !widget.isPreview) _buildAdminMenu(context),
        ],
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') widget.onEdit();
        if (value == 'remove') widget.onClose();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Text(L10n.of(context).edit),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Text(L10n.of(context).closeLive),
        ),
      ],
    );
  }
}
