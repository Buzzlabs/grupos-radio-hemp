import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

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

class _AudioPlayerStreamingState extends State<AudioPlayerStreaming> {
  final player = AudioPlayer();
  web.HTMLAudioElement? _htmlAudioElement;

  double volume = 0.0;
  double _lastNonZeroVolume = 0.3;
  bool _everPlayed = false;

  String title = 'Carregando...';
  String artist = '';
  String artUrl = '';
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  Timer? _fetchMetadataTimer;
  Timer? _progressTimer;
  bool _isLoadingMetadata = false;
  String? _lastSongTitle;

  VoidCallback? _muteListener;
  web.EventListener? _iosUnlockHandler;

  static const double _artSize = 70.0;
  static const double _buttonSize = 40.0;
  static const double _volumeIconSize = 20.0;
  static const double _paddingValue = 15.0;
  static const double _borderRadius = 12.0;

  bool get isIOSWeb {
    if (!kIsWeb) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();

    AudioState.mutedNotifier.value = true;
    volume = 0.0;
    _lastNonZeroVolume = 0.3;

    _initAudio();
    _fetchNowPlaying();
    _fetchMetadataTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _fetchNowPlaying());
    _startProgressTimer();

    _muteListener = () async {
      await _handleMuteChange();
    };
    AudioState.mutedNotifier.addListener(_muteListener!);
  }

  void _initAudio() async {
    final streamUrl = dotenv.env['AUDIO_PLAYER_URL'] ?? '';

    if (isIOSWeb) {
      try {
        _htmlAudioElement = web.HTMLAudioElement();
        final el = _htmlAudioElement!;
        el.src = streamUrl;
        el.preload = 'none';
        el.crossOrigin = 'anonymous';
        el.muted = true;
        el.setAttribute('playsinline', 'true');
        el.setAttribute('webkit-playsinline', 'true');

        el.style.position = 'fixed';
        el.style.left = '-9999px';
        el.style.opacity = '0';

        el.addEventListener(
          'error',
          ((web.Event event) {
            debugPrint('Erro no HTML Audio: $event');
          }).toJS,
        );

        web.document.body!.appendChild(el);
        el.load();

        _installIOSAudioUnlock();
      } catch (e) {
        debugPrint('Erro ao criar HTMLAudioElement (iOS): $e');
      }
    } else {
      try {
        await player.setUrl(streamUrl);
        await player.setVolume(volume);
      } catch (e) {
        debugPrint('Erro ao inicializar just_audio: $e');
      }
    }
  }

  void _installIOSAudioUnlock() {
    if (!isIOSWeb || _htmlAudioElement == null) return;

    _iosUnlockHandler = ((web.Event e) {
      try {
        _htmlAudioElement!.muted = true;
        _htmlAudioElement!.play().toDart.then((_) {
          _htmlAudioElement!.pause();
          _htmlAudioElement!.currentTime = 0;
        }).catchError((_) {});
      } finally {
        if (_iosUnlockHandler != null) {
          web.window
              .removeEventListener('touchstart', _iosUnlockHandler!, true.toJS);
          web.window
              .removeEventListener('touchend', _iosUnlockHandler!, true.toJS);
          web.window.removeEventListener(
              'pointerdown', _iosUnlockHandler!, true.toJS);
          web.window
              .removeEventListener('click', _iosUnlockHandler!, true.toJS);
          _iosUnlockHandler = null;
        }
      }
    }).toJS;

    web.window.addEventListener('touchstart', _iosUnlockHandler, true.toJS);
    web.window.addEventListener('touchend', _iosUnlockHandler, true.toJS);
    web.window.addEventListener('pointerdown', _iosUnlockHandler, true.toJS);
    web.window.addEventListener('click', _iosUnlockHandler, true.toJS);
  }

  Future<void> _handleMuteChange() async {
    final shouldMute = AudioState.mutedNotifier.value;

    try {
      if (isIOSWeb && _htmlAudioElement != null) {
        _htmlAudioElement!.muted = shouldMute;
        if (!shouldMute) {
          volume = (_lastNonZeroVolume > 0 ? _lastNonZeroVolume : 0.3);
        }
        if (mounted) setState(() {});
        return;
      }

      if (shouldMute) {
        _lastNonZeroVolume = volume > 0 ? volume : _lastNonZeroVolume;
        volume = 0.0;
        await player.setVolume(0.0);
      } else {
        final targetVolume = _lastNonZeroVolume > 0 ? _lastNonZeroVolume : 0.3;
        volume = targetVolume;
        await player.setVolume(targetVolume);

        if (!_everPlayed) {
          try {
            if (player.processingState == ProcessingState.idle ||
                player.processingState == ProcessingState.loading) {
              await player.load();
            }
            await player.play();
            _everPlayed = true;
          } catch (e) {
            debugPrint('Erro ao iniciar reprodução: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao mutar/desmutar: $e');
    }

    if (mounted) setState(() {});
  }

  Future<void> _toggleMuteAndMaybePlay() async {
    if (!isIOSWeb || _htmlAudioElement == null) return;

    final el = _htmlAudioElement!;
    final wasMuted = AudioState.mutedNotifier.value;

    if (wasMuted) {
      el.muted = false;

      if (el.readyState < 2) {
        el.load();
      }

      try {
        await el.play().toDart;
        _everPlayed = true;
        AudioState.mutedNotifier.value = false;
      } catch (e) {
        debugPrint('iOS: play() rejeitado: $e');
      }
    } else {
      try {
        el.pause();
      } catch (_) {}
      el.muted = true;
      AudioState.mutedNotifier.value = true;
    }

    if (mounted) setState(() {});
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (duration.inSeconds > 0 && position.inSeconds < duration.inSeconds) {
        setState(() => position += const Duration(seconds: 1));
      }
    });
  }

  Future<void> _fetchNowPlaying() async {
    if (_isLoadingMetadata) return;
    setState(() => _isLoadingMetadata = true);

    try {
      final response = await http.get(
        Uri.parse(dotenv.env['NOW_PLAYING_URL'] ?? ''),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nowPlaying = data['now_playing'];
        if (nowPlaying != null) {
          final newTitle =
              nowPlaying['song']['title'] ?? L10n.of(context).untitled;
          final newArtist =
              nowPlaying['song']['artist'] ?? L10n.of(context).unknownArtist;
          final newArtUrl = nowPlaying['song']['art'] ?? '';
          final newDuration = Duration(
            seconds: (nowPlaying['duration'] ?? 0).clamp(0, 3600),
          );
          final newElapsed = Duration(seconds: nowPlaying['elapsed'] ?? 0);

          final songChanged = newTitle != _lastSongTitle;
          final elapsedWentBack = newElapsed < position;

          setState(() {
            title = newTitle;
            artist = newArtist;
            artUrl = newArtUrl;
            duration = newDuration;
            if (songChanged || elapsedWentBack || newElapsed.inSeconds == 0) {
              position = newElapsed;
              _lastSongTitle = newTitle;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar metadata: $e');
    } finally {
      if (mounted) setState(() => _isLoadingMetadata = false);
    }
  }

  @override
  void dispose() {
    _fetchMetadataTimer?.cancel();
    _progressTimer?.cancel();
    if (_muteListener != null) {
      AudioState.mutedNotifier.removeListener(_muteListener!);
    }

    if (_iosUnlockHandler != null) {
      web.window
          .removeEventListener('touchstart', _iosUnlockHandler!, true.toJS);
      web.window.removeEventListener('touchend', _iosUnlockHandler!, true.toJS);
      web.window
          .removeEventListener('pointerdown', _iosUnlockHandler!, true.toJS);
      web.window.removeEventListener('click', _iosUnlockHandler!, true.toJS);
      _iosUnlockHandler = null;
    }

    if (isIOSWeb && _htmlAudioElement != null) {
      try {
        _htmlAudioElement!.pause();
        _htmlAudioElement!.remove();
      } catch (e) {
        debugPrint('Erro no cleanup: $e');
      }
    } else {
      player.dispose();
    }
    super.dispose();
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _setVolume(double newVolume) async {
    try {
      if (isIOSWeb && _htmlAudioElement != null) {
        _htmlAudioElement!.volume = newVolume;
      } else {
        await player.setVolume(newVolume);
      }

      volume = newVolume;

      if (newVolume == 0) {
        if (!AudioState.mutedNotifier.value) {
          AudioState.mutedNotifier.value = true;
        }
      } else {
        _lastNonZeroVolume = newVolume;
        if (AudioState.mutedNotifier.value) {
          AudioState.mutedNotifier.value = false;
        }

        if (!_everPlayed) {
          if (isIOSWeb && _htmlAudioElement != null) {
            try {
              await _htmlAudioElement!.play().toDart;
              _everPlayed = true;
            } catch (_) {}
          } else {
            if (player.processingState == ProcessingState.idle ||
                player.processingState == ProcessingState.loading) {
              await player.load();
            }
            await player.play();
            _everPlayed = true;
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao definir volume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        border: Border.all(color: theme.colorScheme.secondary),
        borderRadius: BorderRadius.circular(_borderRadius),
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
                final volumeIcon = isMuted
                    ? Icons.volume_off
                    : (isIOSWeb
                        ? Icons.volume_up
                        : (volume > 0.5 ? Icons.volume_up : Icons.volume_down));

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
                        onPressed: () async {
                          try {
                            if (isIOSWeb) {
                              await _toggleMuteAndMaybePlay();
                            } else {
                              final isMutedNow = AudioState.mutedNotifier.value;
                              AudioState.mutedNotifier.value = !isMutedNow;
                            }
                          } catch (e) {
                            debugPrint('Erro no botão mute: $e');
                          }
                        },
                        child: Icon(
                          volumeIcon,
                          color: theme.colorScheme.primary,
                          size: _volumeIconSize,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isIOSWeb
                          ? _buildIOSVolumeIndicator(theme)
                          : _buildVolumeSlider(theme),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(ThemeData theme) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: theme.colorScheme.onTertiary,
        inactiveTrackColor: theme.colorScheme.onTertiary,
        thumbColor: theme.colorScheme.primary,
        overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      child: Slider(
        value: volume,
        min: 0,
        max: 1,
        onChanged: (v) async {
          await _setVolume(v);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Widget _buildIOSVolumeIndicator(ThemeData theme) {
    final isPlaying = !AudioState.mutedNotifier.value;

    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: theme.colorScheme.onTertiary.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          if (isPlaying) ...[
            Expanded(
              flex: 8,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const Expanded(flex: 2, child: SizedBox()),
          ] else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        : (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
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
        Text(_formatTime(position), style: const TextStyle(fontSize: 11)),
        Text(_formatTime(duration), style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class AudioState {
  static final mutedNotifier = ValueNotifier<bool>(true);
}
