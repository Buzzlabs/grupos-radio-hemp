import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketClient {
  IO.Socket? socket;
  final String url;

  final ValueNotifier<int> liveViewers = ValueNotifier<int>(0);

  SocketClient({this.url = 'http://localhost:3333'});

  void connect() {
    if (socket != null && socket!.connected) {
      debugPrint('[socket] já conectado, ignorando...');
      return;
    }

    socket = IO.io(
      url,
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build(),
    );

    socket!.onConnect((_) {
      debugPrint('[socket] Connected: ${socket!.id}');
    });

    socket!.onDisconnect((reason) {
      debugPrint('[socket] Disconnected → $reason');
      liveViewers.value = 0;
    });

    socket!.on('presence:video', (evt) {
      final count = evt['payload'] ?? 0;
      liveViewers.value = count;
      debugPrint('[socket] PRESENCE video → $count');
    });
  }

  void joinLive() {
    socket?.emit('join_live');
    debugPrint('[socket] join_live enviado');
  }

  void leaveLive() {
    socket?.emit('leave_live');
    debugPrint('[socket] leave_live enviado');
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    liveViewers.value = 0;
  }
}
