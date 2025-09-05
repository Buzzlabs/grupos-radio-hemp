import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:web/web.dart' as web;

class AudioPlayerStreaming extends StatefulWidget {
  const AudioPlayerStreaming({super.key});
  @override
  State<AudioPlayerStreaming> createState() => _AudioPlayerStreamingState();
}

class _AudioPlayerStreamingState extends State<AudioPlayerStreaming>
    with SingleTickerProviderStateMixin {
  final player = AudioPlayer();

  double volume = 0.5;
  double _lastNonZeroVolume = 0.5;

  String title = 'Carregando...';
  String artist = '';
  String artUrl = '';
  Duration duration = Duration.zero;

  int _baseElapsedSec = 0;
  DateTime _baseTimestamp = DateTime.now();

  Timer? _progressTimer;
  Timer? _edgeTimer;
  Timer? _staleTimer;
  Timer? _loadingSafetyTimer;
  final Duration _maxStaleness = const Duration(minutes: 3);

  bool _isLoadingMetadata = false;
  String? _lastSongTitle;

  bool _isLoadingAudio = false;
  StreamSubscription<PlayerState>? _playerStateSub;

  late AnimationController _glowController;

  static const double _artSize = 70.0;
  static const double _buttonSize = 40.0;
  static const double _volumeIconSize = 20.0;
  static const double _paddingValue = 15.0;
  static const double _borderRadius = 12.0;

  bool get isIOSWeb {
    if (!kIsWeb) return false;
    final ua = web.window.navigator.userAgent.toLowerCase();
    final platform = (web.window.navigator.platform ?? '').toLowerCase();

    final isIPhone = ua.contains('iphone') || platform.contains('iphone');
    final isIPad = ua.contains('ipad') || platform.contains('ipad');
    final isIPod = ua.contains('ipod') || platform.contains('ipod');

    final isIPadOS = ua.contains('macintosh') &&
        ua.contains('safari') &&
        !ua.contains('chrome') &&
        (web.window.navigator.maxTouchPoints ?? 0) > 1;

    final isIOSSafari = (ua.contains('safari') &&
            !ua.contains('chrome') &&
            ua.contains('mobile')) ||
        isIPadOS;

    return isIPhone || isIPad || isIPod || isIPadOS || isIOSSafari;
  }

  Duration get _position {
    final secNow =
        _baseElapsedSec + DateTime.now().difference(_baseTimestamp).inSeconds;
    final clamped = secNow.clamp(0, duration.inSeconds);
    return Duration(seconds: clamped);
  }

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    AudioState.mutedNotifier.value = true;

    volume = 0.5;
    _lastNonZeroVolume = 0.5;

    _initAudio();

    AudioState.mutedNotifier.addListener(_applyMutedState);

    _playerStateSub = player.playerStateStream.listen(
      (state) {
        final isBufferingOrLoading =
            state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
        final show = isBufferingOrLoading && !state.playing;
        if (mounted && _isLoadingAudio != show) {
          setState(() => _isLoadingAudio = show);
        }
        if (!show) {
          _loadingSafetyTimer?.cancel();
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isLoadingAudio = false);
        _loadingSafetyTimer?.cancel();
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchNowPlaying();
      _startProgressTimer();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _cancelEdgeAndStale();
    _loadingSafetyTimer?.cancel();
    AudioState.mutedNotifier.removeListener(_applyMutedState);
    _playerStateSub?.cancel();
    player.stop();
    player.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _initAudio() async {
    try {
      if (!isIOSWeb) await player.setVolume(volume);
    } catch (e) {
      debugPrint('Erro ao inicializar just_audio: $e');
    }
  }

  Future<void> _resumeAudioContextIOS() async {
    if (!isIOSWeb) return;
    try {
      final dynWin = web.window as dynamic;
      if (dynWin.AudioContext != null) {
        final ctx = dynWin.AudioContext();
        if (ctx.state != 'running') {
          await ctx.resume();
        }
      } else if (dynWin.webkitAudioContext != null) {
        final ctx = dynWin.webkitAudioContext();
        if (ctx.state != 'running') {
          await ctx.resume();
        }
      }
    } catch (_) {}
  }

  void _setMuted(bool value) {
    if (AudioState.mutedNotifier.value != value) {
      AudioState.mutedNotifier.value = value;
    } else {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      AudioState.mutedNotifier.notifyListeners();
    }
    if (mounted) setState(() {});
  }

  Future<void> _startStream() async {
    if (_isLoadingAudio) return;

    final streamUrl = dotenv.env['AUDIO_PLAYER_URL'] ?? '';
    if (streamUrl.isEmpty) {
      debugPrint('AUDIO_PLAYER_URL vazio');
      return;
    }

    if (mounted) setState(() => _isLoadingAudio = true);

    _loadingSafetyTimer?.cancel();
    _loadingSafetyTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _isLoadingAudio = false);
    });

    try {
      if (isIOSWeb) {
        await _resumeAudioContextIOS();
      } else {
        try {
          await player.setVolume(volume);
        } catch (_) {}
      }

      await player.stop();
      await player.setUrl(streamUrl);
      await player.play();
    } catch (e) {
      debugPrint('Falha ao iniciar áudio (startStream): $e');
      _setMuted(true);
      if (mounted) {
        setState(() => _isLoadingAudio = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Toque novamente para iniciar o áudio')),
        );
      }
      _loadingSafetyTimer?.cancel();
    } finally {
      if (mounted && !player.playing) {
        setState(() => _isLoadingAudio = false);
      }
    }
  }

  Future<void> _togglePlay() async {
    if (_isLoadingAudio) return;

    final isMuted = AudioState.mutedNotifier.value;

    if (!isMuted) {
      _setMuted(true);
      _loadingSafetyTimer?.cancel();
      try {
        await player.stop();
      } catch (_) {}
      if (mounted) setState(() => _isLoadingAudio = false);
      return;
    }

    _setMuted(false);
    await _startStream();
  }

  Future<void> _applyMutedState() async {
    final muted = AudioState.mutedNotifier.value;

    if (muted) {
      try {
        await player.stop();
      } catch (e) {
        debugPrint('pause/stop err: $e');
      }
      if (mounted) setState(() => _isLoadingAudio = false);
      _loadingSafetyTimer?.cancel();
      return;
    }

    if (!isIOSWeb && mounted) {
      await _startStream();
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _cancelEdgeAndStale() {
    _edgeTimer?.cancel();
    _edgeTimer = null;
    _staleTimer?.cancel();
    _staleTimer = null;
  }

  void _scheduleNextChecks() {
    _cancelEdgeAndStale();

    if (duration.inSeconds > 0) {
      final remainingSec = duration.inSeconds - _position.inSeconds;
      final fireIn = Duration(seconds: remainingSec > 1 ? remainingSec - 1 : 1);
      _edgeTimer = Timer(fireIn, () async => _fetchNowPlaying());
    }

    _staleTimer = Timer(_maxStaleness, () async => _fetchNowPlaying());
  }

  Future<void> _fetchNowPlaying() async {
    if (_isLoadingMetadata) return;
    _isLoadingMetadata = true;

    try {
      final url = dotenv.env['NOW_PLAYING_URL'] ?? '';
      if (url.isEmpty) return;

      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nowPlaying = data['now_playing'];
        if (nowPlaying != null) {
          final newTitle =
              nowPlaying['song']?['title'] ?? L10n.of(context).untitled;
          final newArtist =
              nowPlaying['song']?['artist'] ?? L10n.of(context).unknownArtist;
          final newArtUrl = nowPlaying['song']?['art'] ?? '';

          final newDurationSec = _intOr0(nowPlaying['duration']).clamp(0, 3600);
          final newElapsedSec = _intOr0(nowPlaying['elapsed']).clamp(0, 3600);

          final songChanged = newTitle != _lastSongTitle;
          final currentPosSec = _position.inSeconds;
          final elapsedWentBack = newElapsedSec < currentPosSec;

          title = newTitle;
          artist = newArtist;
          artUrl = newArtUrl;
          duration = Duration(seconds: newDurationSec);

          final diff = (newElapsedSec - currentPosSec).abs();
          final serverAhead = !elapsedWentBack;
          if (songChanged || (serverAhead && diff >= 2)) {
            _baseElapsedSec = newElapsedSec;
            _baseTimestamp = DateTime.now();
            _lastSongTitle = newTitle;
          }

          _scheduleNextChecks();

          if (mounted) setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar metadata: $e');
    } finally {
      _isLoadingMetadata = false;
    }
  }

  int _intOr0(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobileViewport = MediaQuery.sizeOf(context).width < 600;
    double dim(double a) => isMobileViewport ? a * 0.78 : a;

    return ValueListenableBuilder<bool>(
      valueListenable: AudioState.mutedNotifier,
      builder: (context, isMuted, _) {
        final isPlaying = !isMuted;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            border: Border.all(
              color: isPlaying
                  ? Colors.orangeAccent.withValues(
                      alpha: dim(0.6 + 0.20 * _glowController.value),
                    )
                  : theme.colorScheme.secondary,
            ),
            borderRadius: BorderRadius.circular(_borderRadius),
            boxShadow: isPlaying
                ? [
                    BoxShadow(
                      color: Colors.orangeAccent.withValues(
                        alpha: dim(0.28 + 0.15 * _glowController.value),
                      ),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(_paddingValue),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMetadataRow(theme),
                const SizedBox(height: 15),
                _buildProgressBar(theme, theme.colorScheme.primary),
                const SizedBox(height: 4),
                _buildTimeLabels(),
                const SizedBox(height: 5),
                ValueListenableBuilder<bool>(
                  valueListenable: AudioState.mutedNotifier,
                  builder: (context, isMuted, _) {
                    return Row(
                      children: [
                        SizedBox(
                          width: _buttonSize,
                          height: _buttonSize,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: const CircleBorder(),
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _isLoadingAudio ? null : _togglePlay,
                            child: _isLoadingAudio
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                : Icon(
                                    _getVolumeIcon(isMuted),
                                    color: theme.colorScheme.primary,
                                    size: _volumeIconSize,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: isIOSWeb
                              ? _buildIOSVolumeIndicator(
                                  theme,
                                  !isMuted,
                                )
                              : _buildVolumeSlider(theme, !isMuted),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getVolumeIcon(bool isMuted) {
    if (isMuted || volume == 0) return Icons.volume_off;
    if (isIOSWeb) return Icons.volume_up;
    if (volume < 0.1) return Icons.volume_mute;
    if (volume < 0.7) return Icons.volume_down;
    return Icons.volume_up;
  }

  Widget _buildVolumeSlider(ThemeData theme, bool isPlaying) {
    const trackHeight = 4.0;
    const hPad = 16.0;
    const secondaryLeadPx = 8.0;
    const featherExtraPx = 10.0;
    const animMs = 300;

    return SizedBox(
      height: 32,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          final trackW = constraints.maxWidth - hPad * 2;
          final activeW = (trackW * volume).clamp(0.0, trackW);
          final playTarget = isPlaying ? 1.0 : 0.0;

          return Stack(
            children: [
              Positioned.fill(
                left: hPad,
                right: hPad,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: trackHeight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onTertiary,
                      borderRadius: BorderRadius.circular(trackHeight / 2),
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                left: hPad,
                right: hPad,
                child: Align(
                  alignment:
                      isRtl ? Alignment.centerRight : Alignment.centerLeft,
                  child: SizedBox(
                    width: activeW,
                    height: trackHeight,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: playTarget),
                      duration: const Duration(milliseconds: animMs),
                      curve: Curves.easeOut,
                      builder: (context, t, _) {
                        final endColor = Color.lerp(
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                          t,
                        )!;

                        final effectiveLead =
                            (secondaryLeadPx + featherExtraPx * t);
                        final stop = activeW > 0
                            ? ((activeW - effectiveLead) / activeW)
                                .clamp(0.0, 1.0)
                            : 1.0;

                        return DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(trackHeight / 2),
                            gradient: LinearGradient(
                              begin: isRtl
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              end: isRtl
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              colors: [
                                theme.colorScheme.primary,
                                endColor,
                              ],
                              stops: [0.0, stop],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // slider por cima (trilha transparente)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: trackHeight,
                  trackShape: const RoundedRectSliderTrackShape(),
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: theme.colorScheme.primary,
                  overlayColor:
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: volume,
                  min: 0,
                  max: 1,
                  onChanged: (v) async => _setVolume(v),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIOSVolumeIndicator(ThemeData theme, bool isPlaying) {
    const double h = 4;
    const double r = 2;
    const double leadPx = 6;
    const animMs = 300;

    return SizedBox(
      height: h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final targetFrac = isPlaying ? 0.8 : 0.0;

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: targetFrac),
            duration: const Duration(milliseconds: animMs),
            curve: Curves.easeOut,
            builder: (context, frac, _) {
              final activeW = (w * frac).clamp(0.0, w);

              return ClipRRect(
                borderRadius: BorderRadius.circular(r),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onTertiary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    if (activeW > 0)
                      Positioned(
                        left: activeW - leadPx,
                        top: 0,
                        bottom: 0,
                        width: leadPx,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                theme.colorScheme.primary
                                    .withValues(alpha: 0.0),
                                theme.colorScheme.primary
                                    .withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: activeW,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _setVolume(double newVolume) async {
    volume = newVolume;
    _lastNonZeroVolume = newVolume > 0 ? newVolume : _lastNonZeroVolume;
    if (isIOSWeb) {
      if (mounted) setState(() {});
      return;
    }
    try {
      await player.setVolume(newVolume);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Erro ao definir volume: $e');
    }
  }

  Widget _buildMetadataRow(ThemeData theme) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: artUrl.isNotEmpty
              ? Image.network(
                  artUrl,
                  width: _artSize,
                  height: _artSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.music_note, size: _artSize),
                )
              : Image.asset(
                  'assets/logo_single_semfundo.png',
                  width: _artSize,
                  height: _artSize,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                artist,
                style: TextStyle(color: theme.hintColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(ThemeData theme, Color primaryColor) {
    final progress = (duration.inSeconds == 0)
        ? 0.0
        : (_position.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
    return LinearProgressIndicator(
      value: progress,
      minHeight: 4,
      backgroundColor: theme.colorScheme.onTertiary,
      color: primaryColor,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildTimeLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_formatTime(_position), style: const TextStyle(fontSize: 11)),
        Text(_formatTime(duration), style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}

class AudioState {
  static final mutedNotifier = ValueNotifier<bool>(true);
}
