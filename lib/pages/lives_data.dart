import 'dart:convert';
import 'package:http/http.dart' as http;

/// Lista global de lives. Preencha ela ao buscar do backend.
List<LiveShow> allLives = [];

/// Busca uma live pelo ID. Retorna null se não encontrar.
LiveShow? getLiveById(String id) {
  try {
    return allLives.firstWhere((live) => live.id == id);
  } catch (e) {
    return null;
  }
}

Future<LiveShow?> fetchLiveById(String id) async {
  try {
    final url = Uri.parse('http://localhost:3333/dashboard/api/streams');
    final response = await http.get(url);

    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body) as List<dynamic>;

    // procura o item que tem o id desejado
    final map = decoded.firstWhere(
      (item) => item['id'].toString() == id,
      orElse: () => null,
    ) as Map<String, dynamic>?;

    if (map == null) return null;

    return LiveShow(
      id: map['id']?.toString() ?? 'id',
      title: map['title'] ?? 'Sem título',
      category: map['isLive'] == true ? 'Ao vivo' : 'Gravação',
      date: map['recordedRelativeTime'] ?? '',
      thumbnailUrl: map['latestThumbnail'] ?? '',
      avatarUrl: map['avatarUrl'] ?? 'assets/logo_single_comfundo.png',
      videoUrl: map['masterPlaylistUrl'] ?? '',
      isLive: map['isLive'] ?? false,
    );
  } catch (e, st) {
    print('Erro em fetchLiveById: $e\n$st');
    return null;
  }
}

class LiveShow {
  final String id;
  final String title;
  final String category;
  final String date;
  final String thumbnailUrl;
  final String videoUrl;
  final String avatarUrl;
  final bool isLive;

  LiveShow({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.thumbnailUrl,
    required this.avatarUrl,
    required this.videoUrl,
    this.isLive = false,
  });
}
