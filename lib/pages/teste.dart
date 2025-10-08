import 'package:flutter/material.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluffychat/widgets/streams_widget.dart';

class Teste extends StatefulWidget {
  final bool enforceMobileMode;
  const Teste({super.key, this.enforceMobileMode = false});

  @override
  State<Teste> createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  bool showBottomMenu = false;
  bool destaqueExpandido = false;
  String? secaoExpandida; // null = nenhuma expandida

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobileMode =
        widget.enforceMobileMode || !FluffyThemes.isColumnMode(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Stack(
        children: [
          Container(color: Colors.blueGrey[900]),

          // Botão para abrir/fechar a gaveta
          Positioned(
            top: 50,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() => showBottomMenu = !showBottomMenu);
              },
              child: Text(showBottomMenu ? 'Fechar gaveta' : 'Abrir gaveta'),
            ),
          ),

          // === GAVETA ANIMADA ===
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: showBottomMenu ? 0 : -550,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 600,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Alça visual ---
                      const SizedBox(height: 8),
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => showBottomMenu = !showBottomMenu),
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // --- Conteúdo principal (2/3 e 1/3) ---

                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== Coluna esquerda (2/3) =====
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ROLOU POR AQUI',
                                    style: GoogleFonts.righteous(
                                      textStyle: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w100,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // === Destaques ===
                                          if (secaoExpandida == null ||
                                              secaoExpandida == 'destaques')
                                            StreamsWidget(
                                              streamsWidgetTag: '🔥 Destaques',
                                              onShowMorePressed: () {
                                                setState(() => secaoExpandida =
                                                    'destaques');
                                              },
                                              onBackPressed: () {
                                                setState(() =>
                                                    secaoExpandida = null);
                                              },
                                            ),

                                          const SizedBox(height: 24),

                                          // === Amendoshow ===
                                          if (secaoExpandida == null ||
                                              secaoExpandida == 'amendoshow')
                                            StreamsWidget(
                                              streamsWidgetTag: '🥜 Amendoshow',
                                              onShowMorePressed: () {
                                                setState(() => secaoExpandida =
                                                    'amendoshow');
                                              },
                                              onBackPressed: () {
                                                setState(() =>
                                                    secaoExpandida = null);
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 24),

                            // ===== Coluna direita (1/3) =====
                            Expanded(
                              flex: 1,
                              child: Container(
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
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // eventos (placeholder)
                                    Expanded(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          children: [
                                            for (var i = 0; i < 6; i++) ...[
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 12),
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  color: Colors.black87,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Evento #$i',
                                                    style:
                                                        GoogleFonts.righteous(
                                                      textStyle:
                                                          const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
