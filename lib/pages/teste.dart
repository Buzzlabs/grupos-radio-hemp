import 'package:flutter/material.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluffychat/widgets/streams_widget.dart';

// Tentativa de gaveta móvel
class Teste extends StatefulWidget {
  final bool enforceMobileMode;
  const Teste({super.key, this.enforceMobileMode = false});

  @override
  _TesteState createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  bool showBottomMenu = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobileMode =
        widget.enforceMobileMode || !FluffyThemes.isColumnMode(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Stack(
        children: [
          // Fundo da tela principal
          Container(color: Colors.blueGrey[900]),

          // Botão para abrir/fechar a gaveta (só para testar)
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

                    // --- Conteúdo principal da gaveta ---
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== Coluna esquerda (streams) =====
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
                                  const StreamsWidget(),
                                  const SizedBox(width: 24),
                                ],
                              ),
                            ),

                            const SizedBox(width: 24),

                            // ===== Coluna direita (eventos) =====
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

                                    // Scroll interno
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// // Código da gaveta imóvel
// class Teste extends StatelessWidget {
//   final bool enforceMobileMode;
//   const Teste({super.key, this.enforceMobileMode = false});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isMobileMode =
//         enforceMobileMode || !FluffyThemes.isColumnMode(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.primary,
//       body: Stack(
//         children: [
//           // Fundo (tela base, chat)
//           Container(color: Colors.blueGrey[900]),

//           // “Gaveta” fixa
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: 600, // altura fixa
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.onPrimary,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black45,
//                     blurRadius: 12,
//                     offset: Offset(0, -4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // --- Alça (estética apenas) ---
//                   const SizedBox(height: 8),
//                   Center(
//                     child: Container(
//                       width: 40,
//                       height: 5,
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[600],
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // --- Conteúdo da gaveta ---
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // ===== Coluna esquerda (título fixo, restante scrollável) =====
//                           Expanded(
//                             flex: 2,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // --- Cabeçalho fixo ---
//                                 Text(
//                                   'ROLOU POR AQUI',
//                                   style: GoogleFonts.righteous(
//                                     textStyle: TextStyle(
//                                       color: theme.colorScheme.primary,
//                                       fontSize: 25,
//                                       fontWeight: FontWeight.w100,
//                                       decoration: TextDecoration.none,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),

//                                 // --- Conteúdo rolável (Destaques + cards) --- talvez tornar em widget separado
//                                 const StreamsWidget(),

//                                 // espaço entre colunas
//                                 const SizedBox(width: 24),
//                               ],
//                             ),
//                           ),

//                           const SizedBox(width: 24),

//                           // ===== Coluna direita (scroll independente) =====
//                           Expanded(
//                             flex: 1,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: theme.colorScheme.surface,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'PRÓXIMOS EVENTOS',
//                                     style: GoogleFonts.righteous(
//                                       textStyle: TextStyle(
//                                         color: theme.colorScheme.primary,
//                                         fontSize: 25,
//                                         fontWeight: FontWeight.w100,
//                                         decoration: TextDecoration.none,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),

//                                   // --- Scroll interno da coluna direita ---
//                                   Expanded(
//                                     child: SingleChildScrollView(
//                                       physics: const BouncingScrollPhysics(),
//                                       child: Column(
//                                         children: [
//                                           // Lista de eventos (dps pegar do google calendar)
//                                           for (var i = 0; i < 6; i++) ...[
//                                             Container(
//                                               margin: const EdgeInsets.only(
//                                                   bottom: 12),
//                                               height: 70,
//                                               decoration: BoxDecoration(
//                                                 color: Colors.black87,
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                               child: Center(
//                                                 child: Text(
//                                                   'Evento #$i',
//                                                   style: GoogleFonts.righteous(
//                                                     textStyle: const TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 16,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// (WIP) Gaveta arrastável:

// // ============TESTE==========================
// class Teste extends StatelessWidget {
//   final bool enforceMobileMode;
//   const Teste({super.key, this.enforceMobileMode = false});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.primary,
//       body: Stack(
//         children: [
//           // Fundo da tela
//           Container(color: Colors.blueGrey[900]),

//           // Gaveta arrastável
//           _DraggableSheet(theme: theme),
//         ],
//       ),
//     );
//   }
// }

// // ===============GAVETA=========================
// class _DraggableSheet extends StatelessWidget {
//   final ThemeData theme;
//   const _DraggableSheet({required this.theme});

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.6,  // começa ocupando 60% da tela
//       minChildSize: 0.3,      // pode ser retraída até 30%
//       maxChildSize: 0.9,      // pode expandir até 90%
//       builder: (context, scrollController) {
//         return Container(
//           decoration: BoxDecoration(
//             color: theme.colorScheme.onPrimary,
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(30),
//               topRight: Radius.circular(30),
//             ),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black45,
//                 blurRadius: 12,
//                 offset: Offset(0, -4),
//               ),
//             ],
//           ),
//           child: SingleChildScrollView(
//             controller: scrollController, // controla o arraste
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: _ContentSheet(theme: theme),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// //==============CONTEUDO========================
// class _ContentSheet extends StatelessWidget {
//   final ThemeData theme;
//   const _ContentSheet({required this.theme});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ===== Coluna esquerda (título fixo, restante scrollável) =====
//         Expanded(
//           flex: 2,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // --- Cabeçalho fixo ---
//               Text(
//                 'ROLOU POR AQUI',
//                 style: GoogleFonts.righteous(
//                   textStyle: TextStyle(
//                     color: theme.colorScheme.primary,
//                     fontSize: 25,
//                     fontWeight: FontWeight.w100,
//                     decoration: TextDecoration.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // --- Conteúdo rolável (Destaques + cards) --- talvez tornar em widget separado
//               const StreamsWidget(),

//               // espaço entre colunas
//               const SizedBox(width: 24),
//             ],
//           ),
//         ),

//         const SizedBox(width: 24),

//         // ===== Coluna direita (scroll independente) =====
//         Expanded(
//           flex: 1,
//           child: Container(
//             decoration: BoxDecoration(
//               color: theme.colorScheme.surface,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'PRÓXIMOS EVENTOS',
//                   style: GoogleFonts.righteous(
//                     textStyle: TextStyle(
//                       color: theme.colorScheme.primary,
//                       fontSize: 25,
//                       fontWeight: FontWeight.w100,
//                       decoration: TextDecoration.none,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // --- Scroll interno da coluna direita ---
//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     child: Column(
//                       children: [
//                         // Lista de eventos (dps pegar do google calendar)
//                         for (var i = 0; i < 6; i++) ...[
//                           Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             height: 70,
//                             decoration: BoxDecoration(
//                               color: Colors.black87,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Evento #$i',
//                                 style: GoogleFonts.righteous(
//                                   textStyle: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
