import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluffychat/widgets/vods/events_table.dart';

void main() {
  Widget createWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: EventsTable(),
      ),
    );
  }

  testWidgets('mostra loading e depois eventos', (tester) async {
    await tester.pumpWidget(createWidget());

    // loading inicial
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Live Especial'), findsOneWidget);
    expect(find.text('Podcast Semanal'), findsOneWidget);
  });

  testWidgets('renderiza lista de eventos', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Live'), findsWidgets);
  });
}