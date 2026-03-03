// discover_rooms.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
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
      accessType: json['access_type'] == 'private'
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

  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }

  final decoded = jsonDecode(utf8.decode(response.bodyBytes));
  final List roomsJson = decoded['rooms'] ?? [];

  return roomsJson
      .map<DiscoverRoom>((e) => DiscoverRoom.fromJson(e))
      .toList();
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

  if (response.statusCode != 200) return false;

  final decoded = jsonDecode(utf8.decode(response.bodyBytes));
  return decoded['is_admin'] == true;
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

  if (response.statusCode == 403) {
    throw Exception('Você já faz parte do grupo');
  }

  if (response.statusCode != 200) {
    throw Exception('Invite failed: ${response.statusCode}');
  }
}

class DiscoverBundle {
  final String id;
  final String name;
  final int price;
  final List<String> rooms;
  final List<String> keywords;
  final String status;

  DiscoverBundle({
    required this.id,
    required this.name,
    required this.price,
    required this.rooms,
    required this.keywords,
    required this.status,
  });

  bool get isDraft => status == 'draft';

  factory DiscoverBundle.fromJson(Map<String, dynamic> json) {
    return DiscoverBundle(
      id: json['bundle_id'],
      name: json['bundle_name'],
      price: json['price'] ?? 0,
      rooms: List<String>.from(json['rooms'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      status: json['status'] ?? 'published',
    );
  }
}

Future<List<DiscoverBundle>> fetchBundles(Client client) async {
  try {
    final uri = Uri.parse('${client.homeserver}/_synapse/bundles');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${client.accessToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final List bundlesJson = decoded['bundles'] ?? [];

    return bundlesJson
        .map<DiscoverBundle>((e) => DiscoverBundle.fromJson(e))
        .toList();
  } catch (_) {
    return [];
  }
}