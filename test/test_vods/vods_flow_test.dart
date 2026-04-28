import 'package:fluffychat/widgets/vods/live_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluffychat/widgets/vods/vods_widget.dart';
import 'package:go_router/go_router.dart';

void main() {
  Widget createWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1200,
          height: 800,
          child: VodsWidget(
            streamsWidgetTag: 'Teste',
            initialVisibleCount: 3,
          ),
        ),
      ),
    );
  }

  testWidgets('carrega e mostra VODs', (tester) async {
    await tester.pumpWidget(createWidget());

    // estado inicial
    expect(find.text('Nenhum vod encontrado'), findsOneWidget);

    // força passar o delay do fetch
    await tester.pump(const Duration(seconds: 1));

    // agora deve ter cards
    expect(find.byType(LiveCard), findsWidgets);
  });

  testWidgets('clica no LiveCard e navega para VodPlayerView', (tester) async {
    final router = GoRouter(
      initialLocation: '/rooms/123',
      routes: [
        GoRoute(
          path: '/rooms/:roomid',
          builder: (context, state) {
            return const Scaffold(
              body: SizedBox(
                width: 1200,
                height: 800,
                child: VodsWidget(
                  streamsWidgetTag: 'Teste',
                  initialVisibleCount: 3,
                ),
              ),
            );
          },
          routes: [
            GoRoute(
              path: 'vod/:id',
              builder: (context, state) {
                return const Scaffold(
                  body: Text('Vod Player Page'), // marcador simples
                );
              },
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // espera carregar os VODs
    await tester.pump(const Duration(seconds: 1));

    // garante que tem pelo menos 1 card
    expect(find.byType(LiveCard), findsWidgets);

    // clica no primeiro
    await tester.tap(find.byType(LiveCard).first);

    // deixa o router processar
    await tester.pumpAndSettle();

    // verifica se navegou
    expect(find.text('Vod Player Page'), findsOneWidget);
  });
}
