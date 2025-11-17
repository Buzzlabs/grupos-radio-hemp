import 'package:flutter/material.dart';
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
  String? secaoExpandida;
  String selectedTab = 'rolou';

  double _dragOffset = 0;
  double _mobileHeight = 0;
  final double _peekHeight = 52;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileMode = widget.enforceMobileMode || screenWidth < 1200;

    if (_mobileHeight == 0) {
      _mobileHeight = MediaQuery.of(context).size.height * 0.7;
    }

    if (isMobileMode) {
      _dragOffset = -_mobileHeight + _peekHeight;
    } else {
      _dragOffset = -600 + _peekHeight;
    }
  }

  void toggleGaveta() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileMode = widget.enforceMobileMode || screenWidth < 1200;
    final closedOffset =
        isMobileMode ? -_mobileHeight + _peekHeight : -600 + _peekHeight;

    setState(() {
      showBottomMenu = !showBottomMenu;
      _dragOffset = showBottomMenu ? 0 : closedOffset;
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

  Widget _buildWebLayout(ThemeData theme) {
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
              _dragOffset = (_dragOffset - details.delta.dy)
                  .clamp(-600 + _peekHeight, 0);
            });
          },
          onVerticalDragEnd: (details) {
            setState(() {
              if (details.primaryVelocity! < -200) {
                _dragOffset = 0;
                showBottomMenu = true;
              } else if (details.primaryVelocity! > 200) {
                _dragOffset = -600 + _peekHeight;
                showBottomMenu = false;
              } else {
                if (_dragOffset > -600 / 2) {
                  _dragOffset = 0;
                  showBottomMenu = true;
                } else {
                  _dragOffset = -600 + _peekHeight;
                  showBottomMenu = false;
                }
              }
            });
          },
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
                  const SizedBox(height: 8),
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
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 24),
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
                                ],
                              ),
                              // Container(
                              //   height: 1,
                              //   margin: const EdgeInsets.symmetric(horizontal: 8),
                              //   color:
                              //       theme.colorScheme.primary.withOpacity(0.6),
                              // ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_mostrarSecao("destaques"))
                                        VodsWidget(
                                          initialVisibleCount: 6,
                                          loadMoreCount: 3,
                                          numColumns: 5,
                                          filter: "",
                                          filterOnServer: false,
                                          showHeader: true,
                                          streamsWidgetTag: 'Destaques',
                                          onShowMorePressed: () {
                                            setState(() {
                                              if (secaoExpandida ==
                                                  'destaques') {
                                                secaoExpandida = null;
                                              } else {
                                                secaoExpandida = 'destaques';
                                                showBottomMenu = true;
                                                _dragOffset = 0;
                                              }
                                            });
                                          },
                                          onBackPressed: () {
                                            setState(
                                                () => secaoExpandida = null);
                                          },
                                        ),
                                      const SizedBox(height: 5),
                                      if (_mostrarSecao("legal"))
                                        VodsWidget(
                                          filter: 'legal',
                                          initialVisibleCount: 3,
                                          loadMoreCount: 3,
                                          numColumns: 3,
                                          showHeader: true,
                                          streamsWidgetTag: 'Legal',
                                          onShowMorePressed: () {
                                            setState(() {
                                              if (secaoExpandida == 'legal') {
                                                secaoExpandida = null;
                                              } else {
                                                secaoExpandida = 'legal';
                                                showBottomMenu = true;
                                                _dragOffset = 0;
                                              }
                                            });
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

                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                'PRÓXIMOS EVENTOS',
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
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
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildMobileLayout(ThemeData theme) {
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
                _dragOffset = (_dragOffset - details.delta.dy)
                    .clamp(-_mobileHeight + _peekHeight, 0);
              });
            },
            onVerticalDragEnd: (details) {
              setState(() {
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: Center(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final isSmall = constraints.maxWidth < 1000;

                                  return FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 35),
                                          child: _buildTabButton(
                                            theme,
                                            isSmall
                                                ? 'Rolou'
                                                : 'Rolou por aqui',
                                            'rolou',
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 35),
                                          child: _buildTabButton(
                                            theme,
                                            isSmall
                                                ? 'Eventos'
                                                : 'Próximos eventos',
                                            'eventos',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Flexible(
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
                                    if (_mostrarSecao('destaques'))
                                      VodsWidget(
                                        numColumns: 2,
                                        initialVisibleCount: 4,
                                        loadMoreCount: 2,
                                        streamsWidgetTag: 'Destaque',
                                        onShowMorePressed: () {
                                          setState(() =>
                                              secaoExpandida = 'destaques');
                                        },
                                        onBackPressed: () {
                                           setState(() {
                                                if (secaoExpandida ==
                                                    'destaques') {
                                                  secaoExpandida = null;
                                                } else {
                                                  secaoExpandida = 'destaques';
                                                  showBottomMenu = true;
                                                  _dragOffset = 0;
                                                }
                                              });
                                        },
                                      ),

                                      if (_mostrarSecao('legal'))
                                      VodsWidget(
                                        numColumns: 2,
                                        initialVisibleCount: 4,
                                        loadMoreCount: 2,
                                        streamsWidgetTag: 'Legal',
                                        onShowMorePressed: () {
                                          setState(() =>
                                              secaoExpandida = 'legal');
                                        },
                                        onBackPressed: () {
                                          setState(() {
                                                if (secaoExpandida == 'legal') {
                                                  secaoExpandida = null;
                                                } else {
                                                  secaoExpandida = 'legal';
                                                  showBottomMenu = true;
                                                  _dragOffset = 0;
                                                }
                                              });
                                        },
                                      ),
                                  ],
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const EventsTable(),
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

  Widget _buildTabButton(ThemeData theme, String label, String id) {
    final isSelected = selectedTab == id;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = id),
      child: Column(
        children: [
          SizedBox(
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

  bool _mostrarSecao(String nome) {
    // se nenhuma seção está expandida, mostra todas
    if (secaoExpandida == null) return showBottomMenu;

    // se existe seção expandida, mostra só ela
    return showBottomMenu && secaoExpandida == nome;
  }
}
