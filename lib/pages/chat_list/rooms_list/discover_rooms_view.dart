import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

enum RoomAccessType { free, paid }

class DiscoverRoom {
  final String roomId;
  final String name;
  final String keyword;
  final RoomAccessType accessType;
  final int price;
  final int memberCount;

  DiscoverRoom({
    required this.roomId,
    required this.name,
    required this.keyword,
    required this.accessType,
    required this.price,
    required this.memberCount,
  });

  factory DiscoverRoom.fromJson(Map<String, dynamic> json) {
    return DiscoverRoom(
      roomId: json['room_id'],
      name: json['name'] ?? 'Sem nome',
      keyword: json['keyword'],
      accessType:
          json['access_type'] == 'paid'
              ? RoomAccessType.paid
              : RoomAccessType.free,
      price: json['price'] ?? 0,
      memberCount: json['member_count'] ?? 0,
    );
  }
} 


Future<List<DiscoverRoom>> fetchDiscoverRooms(Client client) async {
  final uri =
      Uri.parse('${client.homeserver}/_synapse/room_service/discover');

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
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }

  final decoded = jsonDecode(utf8.decode(response.bodyBytes));

  final List roomsJson = decoded['rooms'];

  return roomsJson
      .map<DiscoverRoom>((e) => DiscoverRoom.fromJson(e))
      .toList();
}



Future<void> inviteToRoom({
  required Client client,
  required String keyword,
  required String userId,
}) async {
  final uri =
      Uri.parse('${client.homeserver}/_synapse/room_service/invite');

  final response = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer ${client.accessToken}',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'keyword': keyword,
      'user_id': userId,
    }),
  );

  debugPrint('INVITE STATUS: ${response.statusCode}');
  debugPrint('INVITE BODY: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception(
        'Invite failed: ${response.statusCode} ${response.body}');
  }
}


class DiscoverRoomsView extends StatefulWidget {
  const DiscoverRoomsView({super.key});

  @override
  State<DiscoverRoomsView> createState() => _DiscoverRoomsViewState();
}

class _DiscoverRoomsViewState extends State<DiscoverRoomsView> {
  late Future<List<DiscoverRoom>> future;


  @override
  void initState() {
    super.initState();
    final client = Matrix.of(context).client;
    future = fetchDiscoverRooms(client);
  }


  static const double _bottomButtonHeight = 72;
@override
Widget build(BuildContext context) {
  final client = Matrix.of(context).client;
  final theme = Theme.of(context);
  final userId = client.userID.toString();


  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Descobrir Grupos',
        style: TextStyle(
          color: theme.colorScheme.chatlistDiscoverTextColor,
        ),
      ),

    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: theme.colorScheme.chatlistDiscoverButtonColor,
                foregroundColor:
                    theme.colorScheme.chatlistDiscoverButtonTextColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Novo Grupo'),
              onPressed: () {
                context.go('/rooms/newgroup');
              },
            ),
          ],
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
          padding: const EdgeInsets.only(bottom: _bottomButtonHeight + 24),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      color: theme.colorScheme.chatlistDiscoverTileGroupNameTextColor,
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
                          color: theme.colorScheme.chatlistDiscoverTileDescriptionTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: theme.colorScheme.chatlistDiscoverTileDescriptionTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${room.memberCount} participantes',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.chatlistDiscoverTileDescriptionTextColor,
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
                        color: theme.colorScheme.chatlistDiscoverButtonTextColor,
                      ),
                    ),
                    onPressed: () async {
                      if (room.accessType == RoomAccessType.paid) {
                        final approved = await _showFakePayment(context, room.price);
                        if (!approved) return;
                      }


                      try {
                        await inviteToRoom(
                          client: client,
                          keyword: room.keyword,
                          userId: userId, 
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Entrou no grupo ${room.name}')),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Falha ao entrar: $e')),
                          );
                        }
                      }
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
