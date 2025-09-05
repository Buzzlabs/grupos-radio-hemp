import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketClient {
  IO.Socket? socket;
  final String url;

  // 🔢 contadores separados
  final ValueNotifier<int> audioViewers = ValueNotifier<int>(0);
  final ValueNotifier<int> liveViewers = ValueNotifier<int>(0);

  SocketClient({this.url = 'http://localhost:3333'});

  void connect() {
    if (socket != null && socket!.connected) {
      print('[socket] já conectado, ignorando...');
      return;
    }

    socket = IO.io(
      url,
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build(),
    );

    socket!.onConnect((_) {
      print('[socket] Connected: ${socket!.id}');
    });

    socket!.onDisconnect((reason) {
      print('[socket] Disconnected → $reason');
      audioViewers.value = 0;
      liveViewers.value = 0;
    });

    // 🔊 ouvindo presença de áudio
    socket!.on('presence:audio', (evt) {
      final count = evt['payload'] ?? 0;
      audioViewers.value = count;
      print('[socket] PRESENCE audio → $count');
    });

    // 📺 ouvindo presença de vídeo/live
    socket!.on('presence:video', (evt) {
      final count = evt['payload'] ?? 0;
      liveViewers.value = count;
      print('[socket] PRESENCE video → $count');
    });
  }

  // helpers para avisar o servidor em qual "sala" contar
  void joinAudio() {
    socket?.emit('join_audio');
    print('[socket] join_audio enviado');
  }

  void leaveAudio() {
    socket?.emit('leave_audio');
    print('[socket] leave_audio enviado');
  }

  void joinLive() {
    socket?.emit('join_live');
    print('[socket] join_live enviado');
  }

  void leaveLive() {
    socket?.emit('leave_live');
    print('[socket] leave_live enviado');
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    audioViewers.value = 0;
    liveViewers.value = 0;
  }
}
