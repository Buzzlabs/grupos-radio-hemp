import 'package:flutter/material.dart';
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
  final bool showHeader;
  const EventsTable({required this.showHeader, super.key});

  @override
  State<EventsTable> createState() => _EventsTableState();
}

class _EventsTableState extends State<EventsTable> {
  List<Events> allEvents = [];

  Future<void> _fetchEvents() async {
    final baseUrl = 'https://chat.radiohemp.com';
    final url = Uri.parse('$baseUrl/api/calendar/events');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      final items = decoded['items'];
      if (items == null || items is! List) {
        throw Exception('Campo "items" ausente ou inválido');
      }

      final fetchedEvents =
          items.map<Events>((dynamic item) => Events.fromJson(item)).toList();

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

    if (_isSameDay(eventDate, today)) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.secondary;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime eventDate) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    if (_isSameDay(eventDate, today)) {
      return 'Hoje';
    } else if (_isSameDay(eventDate, tomorrow)) {
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
          if (widget.showHeader)
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
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  decoration: BoxDecoration(
                                    color: eventColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: eventColor.withOpacity(0.05),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_formatDate(dateTime)} \n ${_formatTime(dateTime)}',
                                          style: TextStyle(
                                            color: eventColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            event.summary,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
