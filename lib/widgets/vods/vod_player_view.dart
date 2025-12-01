import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';


class VodPlayerView extends StatefulWidget {
  final dynamic controller;
  final String title;
  final String avatarUrl;
  final String playbackUrl;
  final String date;
  final String category;
  final String viewId;
  final String id;
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
    required this.date,
    required this.category,
    required this.id,
    required this.isAdmin,
    required this.isPreview,
    required this.onClose,
    required this.onEdit,
  });

  @override
  State<VodPlayerView> createState() => _VodPlayerViewState();
}

class _VodPlayerViewState extends State<VodPlayerView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1200;
    final videoWidth = isMobile ? screenWidth : screenWidth * 0.7;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1370,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: HtmlElementView(viewType: widget.viewId),
                  ),
                ),
              ),
              const SizedBox(height: 12),
          
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(widget.avatarUrl),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
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
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3,),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.date,
                        style: TextStyle(
                          color: theme.colorScheme.tertiary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3,),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.category,
                        style: TextStyle(
                          color: theme.colorScheme.tertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        final roomId = GoRouterState.of(context)
                            .pathParameters['roomid'];
          
                        final shareLink =
                            'https://grupos.radiohemp.com/#/rooms/$roomId/vod/${widget.id}';
                        Clipboard.setData(ClipboardData(text: shareLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Link copiado!', style: TextStyle(color: Theme.of(context).colorScheme.tertiary),)),
                        );
                      },
                      icon: Icon(
                        Icons.share,
                        size: 18,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() => _expanded = !_expanded);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedCrossFade(
                          firstChild: Text(
                            "Aqui vai uma descrição do VOD. Pode ser várias linhas de texto e só vai aparecer 2. Se clicar no mostrar mais, deve aparecer o resto. blalablablalablablalablablalablablalabla",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.tertiary,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          secondChild: Text(
                            "Aqui vai uma descrição do VOD. Pode ser várias linhas de texto e só vai aparecer 2. Se clicar no mostrar mais, deve aparecer o resto. blalablablalablablalablablalablablalabla",
                            style: TextStyle(
                              color: theme.colorScheme.tertiary,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          crossFadeState: _expanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _expanded ? "mostrar menos" : "…mais",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
