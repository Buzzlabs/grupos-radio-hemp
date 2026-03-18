import 'dart:async';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:provider/provider.dart';
import 'vod_player_view.dart';
import 'package:fluffychat/utils/socket_client.dart';
import 'dart:js_util' as js_util;

class VodPlayer extends StatefulWidget {
  final String playbackUrl;
  final String avatarUrl;
  final String title;
  final String date;
  final String category;
  final String id;
  final bool isAdmin;
  final bool? isPreview;
  final VoidCallback? onClose;
  final VoidCallback? onEdit;

  const VodPlayer({
    super.key,
    required this.id,
    required this.avatarUrl,
    required this.playbackUrl,
    required this.title,
    required this.date,
    required this.category,
    required this.isAdmin,
    this.onClose,
    this.onEdit,
    this.isPreview = false,
  });

  @override
  State<VodPlayer> createState() => VodPlayerController();
}

class VodPlayerController extends State<VodPlayer> {
  final positionNotifier = ValueNotifier<Offset>(const Offset(16, 16));
  final widthNotifier = ValueNotifier<double>(0);
  final aspectRatio = 16 / 9;

  double get width => widthNotifier.value;
  double get height => width / aspectRatio;
  Offset get position => positionNotifier.value;

  bool get isPreview => widget.isPreview ?? false;

  late SocketClient socketClient;

  late String viewId;
  web.HTMLVideoElement? videoElement;
  bool htmlElementsCreated = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();

    viewId = 'vod-player-${DateTime.now().millisecondsSinceEpoch}';

    _createHtmlVideo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketClient = Provider.of<SocketClient>(context, listen: false);
      if (!isPreview) socketClient.joinLive();
    });
  }

  void initializeIfNeeded(double defaultWidth) {
    if (widthNotifier.value == 0) {
      widthNotifier.value = defaultWidth;
    }
  }

  void setPosition(Offset newPosition, double maxWidth, double maxHeight,
      bool isMobileMode,) {
    if (!mounted) return;

    final dx = isMobileMode ? position.dx : newPosition.dx.clamp(16, maxWidth);
    final dy = newPosition.dy.clamp(16, maxHeight);
    positionNotifier.value = Offset(dx.toDouble(), dy.toDouble());
  }

  void resize(double deltaX, double screenWidth) {
    if (!mounted) return;
    final newWidth =
        (width + deltaX).clamp(screenWidth * 0.3, screenWidth * 0.65);
    widthNotifier.value = newWidth;
  }

  void _createHtmlVideo() {
    if (htmlElementsCreated) return;
    htmlElementsCreated = true;

    videoElement = web.document.createElement('video') as web.HTMLVideoElement
      ..id = '$viewId-video'
      ..autoplay = true
      ..controls = true
      ..muted = false;

    videoElement!.style
      ..width = '100%'
      ..height = '100%'
      ..border = 'none'
      ..borderRadius = '8px'
      ..backgroundColor = 'black'
      ..objectFit = 'cover';

    ui.platformViewRegistry
        .registerViewFactory(viewId, (int id) => videoElement!);

    _attachHls();
  }

  void _attachHls() {
    try {
      final hlsJs = js_util.getProperty(web.window, 'Hls');
      if (hlsJs != null) {
        final supported = js_util.callMethod(hlsJs, 'isSupported', []) as bool?;
        if (supported == true) {
          final hls = js_util.callConstructor(hlsJs, []);
          js_util.callMethod(hls, 'loadSource', [widget.playbackUrl]);
          js_util.callMethod(hls, 'attachMedia', [videoElement]);
        } else {
          videoElement!.src = widget.playbackUrl;
        }
      } else {
        videoElement!.src = widget.playbackUrl;
      }
    } catch (_) {
      videoElement!.src = widget.playbackUrl;
    }
  }

  @override
  void dispose() {
    videoElement?.pause();
    videoElement = null;
    socketClient.leaveLive();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VodPlayerView(
      this,
      date: widget.date,
      category: widget.category,
      id: widget.id,
      title: widget.title,
      playbackUrl: widget.playbackUrl,
      isAdmin: widget.isAdmin,
      isPreview: isPreview,
      avatarUrl: widget.avatarUrl,
      viewId: viewId,
      onClose: widget.onClose ?? () {},
      onEdit: widget.onEdit ?? () {},
    );
  }
}
