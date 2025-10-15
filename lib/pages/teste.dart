import 'package:flutter/material.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluffychat/widgets/streams_widget.dart';
import 'package:fluffychat/widgets/events_table.dart';

class Teste extends StatefulWidget {
  final bool enforceMobileMode;
  const Teste({super.key, this.enforceMobileMode = false});

  @override
  State<Teste> createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  bool showBottomMenu = false;
  String? secaoExpandida; // null = nenhuma expandida
  String selectedTab = 'rolou';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileMode = widget.enforceMobileMode || screenWidth < 1200;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: isMobileMode ? _buildMobileLayout(theme) : _buildWebLayout(theme),
    );
  }

  // === LAYOUT WEB ===
  Widget _buildWebLayout(ThemeData theme) {
    return Stack(
      children: [
        Container(color: Colors.blueGrey[900]),

        // === botão ABRIR/FECHAR A GAVETA ===
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
                    // === PUXADOR ===
                    const SizedBox(height: 8),
                    Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
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
                    ),
                    const SizedBox(height: 8),

                    // === CONTEÚDO DA GAVETA ===
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== COLUNA ESQUERDA =====
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
                                        if (secaoExpandida == null ||
                                            secaoExpandida == 'destaques')
                                          StreamsWidget(
                                            initialVisibleCount: 3,
                                            loadMoreCount: 3,
                                            numColumns: 3,
                                            showHeader: true,
                                            streamsWidgetTag: '🔥 Destaques',
                                            onShowMorePressed: () {
                                              setState(() =>
                                                  secaoExpandida = 'destaques');
                                            },
                                            onBackPressed: () {
                                              setState(
                                                  () => secaoExpandida = null);
                                            },
                                          ),
                                        const SizedBox(height: 24),
                                        if (secaoExpandida == null ||
                                            secaoExpandida == 'amendoshow')
                                          StreamsWidget(
                                            initialVisibleCount: 3,
                                            loadMoreCount: 3,
                                            numColumns: 3,
                                            showHeader: true,
                                            streamsWidgetTag: '🥜 Amendoshow',
                                            onShowMorePressed: () {
                                              setState(() => secaoExpandida =
                                                  'amendoshow');
                                            },
                                            onBackPressed: () {
                                              setState(
                                                () => secaoExpandida = null,
                                              );
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

                          // ===== Coluna direita =====
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: const EventsTable(),
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
    );
  }

  // === LAYOUT MOBILE === (ação de deslizar incompleto e não testado)
  Widget _buildMobileLayout(ThemeData theme) {
    return Stack(
      children: [
        Container(
          color: Colors.blueGrey[900],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabButton(theme, 'Rolou por aqui', 'rolou'),
                      _buildTabButton(theme, 'Próximos eventos', 'eventos'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: selectedTab == 'rolou'
                          ? SingleChildScrollView(
                              key: const ValueKey('rolou'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (secaoExpandida == null ||
                                      secaoExpandida == 'destaques')
                                    StreamsWidget(
                                      numColumns: 2,
                                      initialVisibleCount: 2,
                                      loadMoreCount: 2,
                                      streamsWidgetTag: '🔥 Destaques',
                                      onShowMorePressed: () {
                                        setState(
                                            () => secaoExpandida = 'destaques');
                                      },
                                      onBackPressed: () {
                                        setState(() => secaoExpandida = null);
                                      },
                                    ),
                                  const SizedBox(height: 24),
                                  if (secaoExpandida == null ||
                                      secaoExpandida == 'amendoshow')
                                    StreamsWidget(
                                      numColumns: 2,
                                      initialVisibleCount: 2,
                                      loadMoreCount: 2,
                                      streamsWidgetTag: '🥜 Amendoshow',
                                      onShowMorePressed: () {
                                        setState(() =>
                                            secaoExpandida = 'amendoshow');
                                      },
                                      onBackPressed: () {
                                        setState(() => secaoExpandida = null);
                                      },
                                    ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              key: const ValueKey('eventos'),
                              child: Column(
                                children: [
                                  for (var i = 0; i < 7; i++) ...[
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Evento #$i',
                                          style: GoogleFonts.righteous(
                                            textStyle: const TextStyle(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // === ABAS ===
  Widget _buildTabButton(ThemeData theme, String label, String id) {
    final isSelected = selectedTab == id;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = id),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.righteous(
              textStyle: TextStyle(
                color:
                    isSelected ? theme.colorScheme.primary : Colors.grey[600],
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: 80,
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
