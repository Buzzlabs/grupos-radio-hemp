import 'package:flutter/material.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class Events {
  final String summary;
  final DateTime start;

  Events({
    required this.summary,
    required this.start,
  });

  // Construtor para criar Events a partir do JSON
  factory Events.fromJson(Map<String, dynamic> json) {
    final startJson = json['start'] as Map<String, dynamic>? ?? {};
    final dateTimeStr = startJson['dateTime'] ?? startJson['date'] ?? '';
    return Events(
      summary: json['summary'] as String? ?? 'Sem evento',
      start: DateTime.parse(dateTimeStr),
    );
  }
}

class EventsTable extends StatefulWidget {
  const EventsTable({super.key});

  @override
  State<EventsTable> createState() => _EventsTableState();
}

class _EventsTableState extends State<EventsTable> {
  List<Events> allEvents = [];

  Future<void> _fetchEvents() async {
    final baseUrl = 'http://localhost:3333';
    final url = Uri.parse('$baseUrl/api/calendar/events');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('Resposta inesperada: esperava um array JSON');
      }

      final List<Events> fetchedEvents = decoded.map<Events>((dynamic item) {
        return Events.fromJson(item as Map<String, dynamic>);
      }).toList();

      if (!mounted) return;
      setState(() {
        allEvents = fetchedEvents;
      });
    } on TimeoutException catch (_) {
      debugPrint('Requisição expirou');
    } catch (e, st) {
      debugPrint('Erro ao buscar eventos: $e\n$st');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Color _getEventColor(DateTime eventDate, ThemeData theme) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    if (eventDate.year == today.year &&
        eventDate.month == today.month &&
        eventDate.day == today.day) {
      return theme.colorScheme.primary; // Hoje
    } else if (eventDate.year == tomorrow.year &&
        eventDate.month == tomorrow.month &&
        eventDate.day == tomorrow.day) {
      return theme.colorScheme.secondary; // Amanhã
    } else {
      return theme.colorScheme.secondary; // Futuro
    }
  }

  String _formatDate(DateTime eventDate) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    if (eventDate.year == today.year &&
        eventDate.month == today.month &&
        eventDate.day == today.day) {
      return 'Hoje';
    } else if (eventDate.year == tomorrow.year &&
        eventDate.month == tomorrow.month &&
        eventDate.day == tomorrow.day) {
      return 'Amanhã';
    } else {
      return '${eventDate.day}/${eventDate.month}';
    }
  }

  String _formatTime(DateTime eventDate) {
    return '${eventDate.hour.toString().padLeft(2, '0')}h';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRÓXIMOS EVENTOS',
            style: GoogleFonts.righteous(
              textStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 25,
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: allEvents.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: allEvents.map((event) {
                        final dateTime = event.start;
                        final eventColor = _getEventColor(dateTime, theme);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: eventColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatDate(dateTime),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      _formatTime(dateTime),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  event.summary,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
