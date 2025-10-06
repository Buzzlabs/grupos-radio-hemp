import 'package:flutter/material.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluffychat/widgets/live_card.dart';

class Teste extends StatelessWidget {
  final bool enforceMobileMode;
  const Teste({super.key, this.enforceMobileMode = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobileMode =
        enforceMobileMode || !FluffyThemes.isColumnMode(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Stack(
        children: [
          // Fundo (tela base, chat)
          Container(color: Colors.blueGrey[900]),

          // “Gaveta” fixa (não arrastável tava dando ruim)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 600, // altura fixa
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Alça (estética apenas) ---
                  const SizedBox(height: 8),
                  Center(
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
                  const SizedBox(height: 8),

                  // --- Conteúdo da gaveta ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== Coluna esquerda (título fixo, restante scrollável) =====
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- Cabeçalho fixo ---
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

                                // --- Conteúdo rolável (Destaques + cards) --- talvez tornar em widget separado
                                Expanded( 
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column( 
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '🔥 Destaques',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w100,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // --- Grade de cards --- (dps ajustar para colocar o "mostrar mais")
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 16,
                                          children: List.generate(
                                            12,
                                            (i) => SizedBox(
                                              width: (MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.55 -
                                                      24) /
                                                  3,
                                              child: LiveCard(),
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

                          const SizedBox(width: 24),

                          // ===== Coluna direita (scroll independente) =====
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

                                  // --- Scroll interno da coluna direita ---
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        children: [
                                          // Lista de eventos (dps pegar do google calendar)
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
                                                  style: GoogleFonts.righteous(
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// duvidas:
// - como fazer a gaveta ser arrastável? tentei DraggableScrollableSheet mas n rolou
// - devo transformar o Destaques/ Amendoshow em widget separado? talvez facilite a organização
// - como fazer o "mostrar mais" carregar mais cards?
// - formatação deve estar toda errada (tanto esse arquivo quanto os outros que editei)
// - mobile..?

