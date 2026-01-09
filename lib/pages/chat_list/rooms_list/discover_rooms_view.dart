import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

enum RoomAccessType { free, paid }

class DiscoverRoom {
  final String name;
  final String roomId;
  final RoomAccessType accessType;
  final int memberCount;
  final int price;

  DiscoverRoom({
    required this.name,
    required this.roomId,
    required this.accessType,
    required this.memberCount,
    required this.price,
  });

  factory DiscoverRoom.fromJson(Map<String, dynamic> json) {
    return DiscoverRoom(
      name: json['name'],
      roomId: json['room_id'],
      accessType:
          json['type'] == 'paid' ? RoomAccessType.paid : RoomAccessType.free,
      memberCount: json['member_count'] ?? 0,
      price: json['price'] ?? 0,
    );
  }
} 

Future<List<DiscoverRoom>> fetchDiscoverRooms(Client client) async {
  final uri = Uri.parse(
    '${client.homeserver}/_matrix/admin/rooms',
  );

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer ${client.accessToken}',
      'Content-Type': 'application/json',
    },
  );

  debugPrint('DISCOVER STATUS: ${response.statusCode}');
  debugPrint('DISCOVER BODY: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception(
      'HTTP ${response.statusCode}: ${response.body}',
    );
  }

  final decoded = jsonDecode(utf8.decode(response.bodyBytes));

  if (decoded is! List) {
    throw Exception('Invalid response format');
  }

  return decoded
      .map<DiscoverRoom>(
        (e) => DiscoverRoom.fromJson(e),
      )
      .toList();
}

Future<void> inviteToCommunity({
  required Client client,
  required String community,
}) async {
  final uri = Uri.parse(
    '${client.homeserver}/_matrix/invite',
  );

  final response = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer ${client.accessToken}',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'community': community,
    }),
  );

  debugPrint('INVITE STATUS: ${response.statusCode}');
  debugPrint('INVITE BODY: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception(
      'Invite failed: ${response.statusCode} ${response.body}',
    );
  }
}

class DiscoverRoomsView extends StatefulWidget {
  const DiscoverRoomsView({super.key});

  @override
  State<DiscoverRoomsView> createState() => _DiscoverRoomsViewState();
}

class _DiscoverRoomsViewState extends State<DiscoverRoomsView> {
  late Future<List<DiscoverRoom>> future = Future.value([]);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final client = Matrix.of(context).client;
      setState(() {
        future = fetchDiscoverRooms(client);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Descobrir Grupos',
          style: TextStyle(
            color: theme.colorScheme.chatlistDiscoverTextColor,
          ),
        ),
      ),
      body: FutureBuilder<List<DiscoverRoom>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar grupos',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }

          final rooms = snapshot.data!;

          if (rooms.isEmpty) {
            return const Center(child: Text('Nenhum grupo disponível'));
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(14),
                  color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    title: Text(
                      room.name,
                      style: TextStyle(
                        color: theme
                            .colorScheme.chatlistDiscoverTileGroupNameTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.accessType == RoomAccessType.paid
                              ? 'Premium • R\$ ${(room.price / 100).toStringAsFixed(2)}'
                              : 'Entrada livre',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme
                                .chatlistDiscoverTileDescriptionTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: theme.colorScheme
                                  .chatlistDiscoverTileDescriptionTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${room.memberCount} participantes',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme
                                    .chatlistDiscoverTileDescriptionTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      child: Text(
                        room.accessType == RoomAccessType.free
                            ? 'Entrar'
                            : 'Desbloquear',
                        style: TextStyle(
                          color:
                              theme.colorScheme.chatlistDiscoverButtonTextColor,
                        ),
                      ),
                      onPressed: () async {
                        if (room.accessType == RoomAccessType.paid) {
                          final approved =
                              await _showFakePayment(context, room.price);
                          if (!approved) return;
                        }

                        final community =
                            room.accessType == RoomAccessType.paid
                                ? 'vip'
                                : 'free';

                        await inviteToCommunity(
                          client: client,
                          community: community,
                        );

                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _showFakePayment(BuildContext context, int price) async {
    final theme = Theme.of(context);
    final formatted = 'R\$ ${(price / 100).toStringAsFixed(2)}';

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Pagamento'),
            content: Text('Confirmar pagamento de $formatted ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  'Pagar',
                  style: TextStyle(
                    color: theme.colorScheme.chatlistDiscoverButtonTextColor,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
