import 'package:flutter/material.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluffychat/widgets/vods/vods_widget.dart';
import 'package:fluffychat/widgets/vods/events_table.dart';

class PopUpVods extends StatefulWidget {
  final bool enforceMobileMode;
  const PopUpVods({super.key, this.enforceMobileMode = false});

  @override
  State<PopUpVods> createState() => PopUpVodsState();
}

class PopUpVodsState extends State<PopUpVods> {
  bool showBottomMenu = false;
  String? secaoExpandida; // null = nenhuma expandida
  String selectedTab = 'rolou';

  // === MÉTODO PÚBLICO PARA TOGGLE DA GAVETA ===
  void toggleGaveta() {
    setState(() {
      showBottomMenu = !showBottomMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileMode = widget.enforceMobileMode || screenWidth < 1200;

    return Material(
      type: MaterialType.transparency,
      child: isMobileMode ? _buildMobileLayout(theme) : _buildWebLayout(theme),
    );
  }

  // === LAYOUT WEB ===
  Widget _buildWebLayout(ThemeData theme) {
    return Stack(
      children: [
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
                                        // if (secaoExpandida == null ||
                                        //     secaoExpandida == 'amendoshow')
                                        //   StreamsWidget(
                                        //     filter: 'amendoshow',
                                        //     initialVisibleCount: 3,
                                        //     loadMoreCount: 3,
                                        //     numColumns: 3,
                                        //     showHeader: true,
                                        //     streamsWidgetTag: '🥜 Amendoshow',
                                        //     onShowMorePressed: () {
                                        //       setState(() => secaoExpandida =
                                        //           'amendoshow');
                                        //     },
                                        //     onBackPressed: () {
                                        //       setState(
                                        //         () => secaoExpandida = null,
                                        //       );
                                        //     },
                                        //   ),
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
                              child: const EventsTable(
                                showHeader: true,
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
    );
  }

  // === LAYOUT MOBILE === (ação de deslizar incompleto e não testado)
  // === LAYOUT MOBILE ===
  Widget _buildMobileLayout(ThemeData theme) {
    double _mobileHeight = MediaQuery.of(context).size.height * 0.7;
    const double _peekHeight = 52; // parte visível quando fechada
    double _dragOffset = showBottomMenu ? 0 : -_mobileHeight + _peekHeight;

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          bottom: _dragOffset,
          left: 0,
          right: 0,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                // move a gaveta junto com o dedo, limitando
                _dragOffset = (_dragOffset - details.delta.dy)
                    .clamp(-_mobileHeight + _peekHeight, 0);
              });
            },
            onVerticalDragEnd: (details) {
              setState(() {
                // abre ou fecha dependendo da velocidade ou posição
                if (details.primaryVelocity! < -200) {
                  _dragOffset = 0;
                  showBottomMenu = true;
                } else if (details.primaryVelocity! > 200) {
                  _dragOffset = -_mobileHeight + _peekHeight;
                  showBottomMenu = false;
                } else {
                  if (_dragOffset > -_mobileHeight / 2) {
                    _dragOffset = 0;
                    showBottomMenu = true;
                  } else {
                    _dragOffset = -_mobileHeight + _peekHeight;
                    showBottomMenu = false;
                  }
                }
              });
            },
            child: Container(
              height: _mobileHeight,
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
                    // puxador
                    Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => toggleGaveta(),
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

                    // abas e conteúdo
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 16),
                                _buildTabButton(
                                    theme, 'Rolou por aqui', 'rolou', 200),
                                const SizedBox(width: 24),
                                _buildTabButton(
                                    theme, 'Próximos eventos', 'eventos', 250),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ),
                        );
                      },
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
                                          setState(() =>
                                              secaoExpandida = 'destaques');
                                        },
                                        onBackPressed: () {
                                          setState(() => secaoExpandida = null);
                                        },
                                      ),
                                    const SizedBox(height: 24),
                                    // if (secaoExpandida == null ||
                                    //     secaoExpandida == 'amendoshow')
                                    //   StreamsWidget(
                                    //     filter: 'amendoshow',
                                    //     numColumns: 2,
                                    //     initialVisibleCount: 2,
                                    //     loadMoreCount: 2,
                                    //     streamsWidgetTag: '🥜 Amendoshow',
                                    //     onShowMorePressed: () {
                                    //       setState(() =>
                                    //           secaoExpandida = 'amendoshow');
                                    //     },
                                    //     onBackPressed: () {
                                    //       setState(() => secaoExpandida = null);
                                    //     },
                                    //   ),
                                  ],
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const EventsTable(
                                  showHeader: false,
                                ),
                              ),
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

  // === ABAS ===
  Widget _buildTabButton(
      ThemeData theme, String label, String id, double width) {
    final isSelected = selectedTab == id;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = id),
      child: Column(
        children: [
          SizedBox(
            width: width, // Define a largura máxima da aba
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.righteous(
                textStyle: TextStyle(
                  color:
                      isSelected ? theme.colorScheme.primary : Colors.grey[600],
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
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
