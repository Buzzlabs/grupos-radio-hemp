import 'dart:convert';

import 'package:flutter/material.dart' hide Visibility;

import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';

import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/chat_access_settings/chat_access_settings_page.dart';
import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_modal_action_popup.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_ok_cancel_alert_dialog.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_text_input_dialog.dart';
import 'package:fluffychat/widgets/future_loading_dialog.dart';
import 'package:fluffychat/widgets/matrix.dart';

class ChatAccessSettings extends StatefulWidget {
  final String roomId;
  const ChatAccessSettings({required this.roomId, super.key});

  @override
  State<ChatAccessSettings> createState() => ChatAccessSettingsController();
}

class ChatAccessSettingsController extends State<ChatAccessSettings> {
  bool joinRulesLoading = false;
  bool visibilityLoading = false;
  bool historyVisibilityLoading = false;
  bool guestAccessLoading = false;
  bool businessVisible = true;
  final TextEditingController priceController = TextEditingController();
  Room get room => Matrix.of(context).client.getRoomById(widget.roomId)!;
  bool isAdmin = false;
  bool isAdminLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessVisibility();
    _loadAdminStatus();
  }

  Future<void> _loadBusinessVisibility() async {
    final client = Matrix.of(context).client;

    try {
      final res = await client.httpClient.post(
        Uri.parse('${client.homeserver}/_synapse/room_service/getvisibility'),
        headers: {
          'Authorization': 'Bearer ${client.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'room_id': room.id,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception(res.body);
      }

      final json = jsonDecode(res.body);
      final visible = json['visible'] as bool;
      final price = json['price'] as int;

      if (!mounted) return;

      setState(() {
        businessVisible = visible;
        priceController.text = (price / 100).toString();
      });
    } catch (e, s) {
      Logs().w('Failed to load business visibility', e, s);
    }
  }

  String get roomVersion =>
      room
          .getState(EventTypes.RoomCreate)!
          .content
          .tryGet<String>('room_version') ??
      'Unknown';

  List<JoinRules> get availableJoinRules {
    final joinRules = Set<JoinRules>.from(JoinRules.values);

    final roomVersionInt = int.tryParse(roomVersion);

    if (roomVersionInt != null && roomVersionInt <= 6) {
      joinRules.remove(JoinRules.knock);
    }

    joinRules.remove(JoinRules.restricted);
    joinRules.remove(JoinRules.knockRestricted);

    final currentJoinRule = room.joinRules;
    if (currentJoinRule != null) {
      joinRules.add(currentJoinRule);
    }

    return joinRules.toList();
  }

  Future<void> _loadAdminStatus() async {
    final client = Matrix.of(context).client;

    try {
      final admin = await fetchIsAdmin(client);
      if (!mounted) return;

      setState(() {
        isAdmin = admin;
        isAdminLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isAdmin = false;
        isAdminLoading = false;
      });
    }
  }

 Future<void> setPrice() async {
  if (!isAdmin) return;

  final client = Matrix.of(context).client;
  final theme = Theme.of(context);

  final parsed = int.tryParse(priceController.text.trim());

  if (parsed == null || parsed < 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Preço inválido',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
    return;
  }

  try {
    await client.httpClient.post(
  Uri.parse('${client.homeserver}/_synapse/room_service/changeprice'),
  headers: {
    'Authorization': 'Bearer ${client.accessToken}',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'room_id': room.id,
    'price': parsed * 100,
  }),
);
    
  } catch (e, s) {
    Logs().w('Failed to change price', e, s);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toLocalizedString(context),
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      );
    }
  }
}


  Future<bool> fetchIsAdmin(Client client) async {
    final uri =
        Uri.parse('${client.homeserver}/_synapse/room_service/is_admin');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${client.accessToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return false;
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return decoded['is_admin'] == true;
  }

  Future<void> setBusinessVisibility(bool visible) async {
    final theme = Theme.of(context);
    final client = Matrix.of(context).client;

    int price;

    if (!visible) {
      price = 0;
    } else {
      final parsed = int.tryParse(priceController.text.trim());

      // Se for público, preço pode ser 0
      if (room.joinRules == JoinRules.public) {
        price = parsed ?? 0;
      } else {
        // privado precisa ser > 0
        if (parsed == null || parsed <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Preço obrigatório para chats privados visíveis',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          );
          return;
        }
        price = parsed;
      }
    }

    setState(() => visibilityLoading = true);

    try {
      final res = await client.httpClient.post(
        Uri.parse(
          '${client.homeserver}/_synapse/room_service/changevisibility',
        ),
        headers: {
          'Authorization': 'Bearer ${client.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'room_id': room.id,
          'visible': visible,
          'price': price * 100,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception(res.body);
      }

      setState(() {
        businessVisible = visible;
        if (!visible) {
          priceController.text = '0';
        }
      });
    } catch (e, s) {
      Logs().w('Unable to change business visibility', e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toLocalizedString(context),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => visibilityLoading = false);
      }
    }
  }

  /// Calculates which join rules are available based on the information on
  /// https://spec.matrix.org/v1.11/rooms/#feature-matrix

  void setJoinRule(JoinRules? newJoinRules) async {
    if (newJoinRules == null) return;
    setState(() {
      joinRulesLoading = true;
    });

    try {
      await room.setJoinRules(newJoinRules);
    } catch (e, s) {
      Logs().w('Unable to change join rules', e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toLocalizedString(context),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          joinRulesLoading = false;
        });
      }
    }
  }

  void setHistoryVisibility(HistoryVisibility? historyVisibility) async {
    if (historyVisibility == null) return;
    setState(() {
      historyVisibilityLoading = true;
    });

    try {
      await room.setHistoryVisibility(historyVisibility);
    } catch (e, s) {
      Logs().w('Unable to change history visibility', e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toLocalizedString(context),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          historyVisibilityLoading = false;
        });
      }
    }
  }

  void setGuestAccess(GuestAccess? guestAccess) async {
    if (guestAccess == null) return;
    setState(() {
      guestAccessLoading = true;
    });

    try {
      await room.setGuestAccess(guestAccess);
    } catch (e, s) {
      Logs().w('Unable to change guest access', e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toLocalizedString(context),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          guestAccessLoading = false;
        });
      }
    }
  }

  void updateRoomAction() async {
    final roomVersion = room
        .getState(EventTypes.RoomCreate)!
        .content
        .tryGet<String>('room_version');
    final capabilitiesResult = await showFutureLoadingDialog(
      context: context,
      future: () => room.client.getCapabilities(),
    );
    final capabilities = capabilitiesResult.result;
    if (capabilities == null) return;
    final newVersion = await showModalActionPopup<String>(
      context: context,
      title: L10n.of(context).replaceRoomWithNewerVersion,
      cancelLabel: L10n.of(context).cancel,
      actions: capabilities.mRoomVersions!.available.entries
          .where((r) => r.key != roomVersion)
          .map(
            (version) => AdaptiveModalAction(
              value: version.key,
              label:
                  '${version.key} (${version.value.toString().split('.').last})',
            ),
          )
          .toList(),
    );
    if (newVersion == null ||
        OkCancelResult.cancel ==
            await showOkCancelAlertDialog(
              useRootNavigator: false,
              context: context,
              okLabel: L10n.of(context).yes,
              cancelLabel: L10n.of(context).cancel,
              title: L10n.of(context).areYouSure,
              message: L10n.of(context).roomUpgradeDescription,
              isDestructive: true,
            )) {
      return;
    }
    final result = await showFutureLoadingDialog(
      context: context,
      future: () => room.client.upgradeRoom(room.id, newVersion),
    );
    if (result.error != null) return;
    if (!mounted) return;
    context.go('/rooms/${room.id}');
  }

  Future<void> addAlias() async {
    final domain = room.client.userID?.domain;
    if (domain == null) {
      throw Exception('userID or domain is null! This should never happen.');
    }

    final input = await showTextInputDialog(
      context: context,
      title: L10n.of(context).editRoomAliases,
      prefixText: '#',
      suffixText: domain,
      hintText: L10n.of(context).alias,
    );
    final aliasLocalpart = input?.trim();
    if (aliasLocalpart == null || aliasLocalpart.isEmpty) return;
    final alias = '#$aliasLocalpart:$domain';

    final result = await showFutureLoadingDialog(
      context: context,
      future: () => room.client.setRoomAlias(alias, room.id),
    );
    if (result.error != null) return;
    setState(() {});

    if (!room.canChangeStateEvent(EventTypes.RoomCanonicalAlias)) return;

    final canonicalAliasConsent = await showOkCancelAlertDialog(
      context: context,
      title: L10n.of(context).setAsCanonicalAlias,
      message: alias,
      okLabel: L10n.of(context).yes,
      cancelLabel: L10n.of(context).no,
    );

    final altAliases = room
            .getState(EventTypes.RoomCanonicalAlias)
            ?.content
            .tryGetList<String>('alt_aliases')
            ?.toSet() ??
        {};
    if (room.canonicalAlias.isNotEmpty) altAliases.add(room.canonicalAlias);
    altAliases.add(alias);
    if (canonicalAliasConsent == OkCancelResult.ok) {
      altAliases.remove(alias);
    } else {
      altAliases.remove(room.canonicalAlias);
    }

    await showFutureLoadingDialog(
      context: context,
      future: () => room.client.setRoomStateWithKey(
        room.id,
        EventTypes.RoomCanonicalAlias,
        '',
        {
          'alias': canonicalAliasConsent == OkCancelResult.ok
              ? alias
              : room.canonicalAlias,
          if (altAliases.isNotEmpty) 'alt_aliases': altAliases.toList(),
        },
      ),
    );
  }

  void deleteAlias(String alias) async {
    await showFutureLoadingDialog(
      context: context,
      future: () => room.client.deleteRoomAlias(alias),
    );
    setState(() {});
  }

  // void setChatVisibilityOnDirectory(bool? visibility) async {
  //   final theme = Theme.of(context);

  //   if (visibility == null) return;
  //   setState(() {
  //     visibilityLoading = true;
  //   });

  //   try {
  //     await room.client.setRoomVisibilityOnDirectory(
  //       room.id,
  //       visibility: visibility == true ? Visibility.public : Visibility.private,
  //     );
  //     setState(() {});
  //   } catch (e, s) {
  //     Logs().w('Unable to change visibility', e, s);
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             e.toLocalizedString(context),
  //             style: TextStyle(color: theme.colorScheme.error),
  //           ),
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         visibilityLoading = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ChatAccessSettingsPageView(this);
  }
}
