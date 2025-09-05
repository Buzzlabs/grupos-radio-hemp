import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod;
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/utils/client_manager.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'config/setting_keys.dart';
import 'utils/background_push.dart';
import 'utils/socket_client.dart';
import 'widgets/fluffy_chat_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  Logs().i('Welcome to ${AppConfig.applicationName} <3');
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await vod.init(wasmPath: './assets/assets/vodozemac/');

  Logs().nativeColors = !PlatformInfos.isIOS;
  final store = await SharedPreferences.getInstance();
  final clients = await ClientManager.getClients(store: store);

  if (PlatformInfos.isAndroid &&
      AppLifecycleState.detached == WidgetsBinding.instance.lifecycleState) {
    for (final client in clients) {
      client.backgroundSync = false;
      client.syncPresence = PresenceType.offline;
    }

    BackgroundPush.clientOnly(clients.first);
    WidgetsBinding.instance.addObserver(AppStarter(clients, store));
    Logs().i(
      '${AppConfig.applicationName} started in background-fetch mode. No GUI will be created unless the app is no longer detached.',
    );
    return;
  }

  Logs().i(
    '${AppConfig.applicationName} started in foreground mode. Rendering GUI...',
  );
  await startGui(clients, store);
}

Future<void> startGui(List<Client> clients, SharedPreferences store) async {
  String? pin;
  if (PlatformInfos.isMobile) {
    try {
      pin =
          await const FlutterSecureStorage().read(key: SettingKeys.appLockKey);
    } catch (e, s) {
      Logs().d('Unable to read PIN from Secure storage', e, s);
    }
  }

  final firstClient = clients.firstOrNull;
  await firstClient?.roomsLoading;
  await firstClient?.accountDataLoading;

  final socketClient = SocketClient();
  socketClient.connect();

  runApp(
    MultiProvider(
      providers: [
        Provider<SocketClient>.value(value: socketClient),
      ],
      child: FluffyChatApp(clients: clients, pincode: pin, store: store),
    ),
  );
}

class AppStarter with WidgetsBindingObserver {
  final List<Client> clients;
  final SharedPreferences store;
  bool guiStarted = false;

  AppStarter(this.clients, this.store);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (guiStarted) return;
    if (state == AppLifecycleState.detached) return;

    Logs().i(
      '${AppConfig.applicationName} switches from the detached background-fetch mode to ${state.name} mode. Rendering GUI...',
    );
    for (final client in clients) {
      client.backgroundSync = true;
      client.syncPresence = PresenceType.online;
    }
    startGui(clients, store);
    guiStarted = true;
  }
}
