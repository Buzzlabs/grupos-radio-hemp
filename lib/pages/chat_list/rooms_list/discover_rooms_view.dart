// discover_rooms_view.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:matrix/matrix.dart';

import 'discover_rooms.dart';

class DiscoverRoomsView extends StatefulWidget {
  const DiscoverRoomsView({super.key});

  @override
  State<DiscoverRoomsView> createState() => _DiscoverRoomsViewState();
}

class _DiscoverRoomsViewState extends State<DiscoverRoomsView> {
  late Future<List<DiscoverRoom>> roomsFuture;
  late Future<List<DiscoverBundle>> bundlesFuture;

  bool isAdmin = false;
  bool adminLoaded = false;

  static const double _bottomButtonHeight = 72;

  @override
  void initState() {
    super.initState();
    final client = Matrix.of(context).client;

    roomsFuture = fetchDiscoverRooms(client);
    bundlesFuture = fetchBundles(client);

    fetchIsAdmin(client).then((value) {
      if (!mounted) return;
      setState(() {
        isAdmin = value;
        adminLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final theme = Theme.of(context);
    final userId = client.userID.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Descobrir Grupos',
          style: TextStyle(
            color: theme.colorScheme.chatlistDiscoverTextColor,
          ),
        ),
      ),
      bottomNavigationBar: (!adminLoaded || !isAdmin)
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.chatlistDiscoverRoomButtonColor,
                        foregroundColor: theme
                            .colorScheme.chatlistDiscoverRoomButtonTextColor,
                      ),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Novo Bundle'),
                      onPressed: () {
                        context.go('/rooms/newbundle');
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.chatlistDiscoverRoomButtonColor,
                        foregroundColor: theme
                            .colorScheme.chatlistDiscoverRoomButtonTextColor,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Novo Grupo'),
                      onPressed: () {
                        context.go('/rooms/newgroup');
                      },
                    ),
                  ],
                ),
              ),
            ),
      body: FutureBuilder(
        future: Future.wait([roomsFuture, bundlesFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

           if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Text('Erro ao carregar dados', style: TextStyle(color: theme.colorScheme.error),),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          final client = Matrix.of(context).client;
                          roomsFuture = fetchDiscoverRooms(client);
                          bundlesFuture = fetchBundles(client);
                        });
                      },
                      child: Text('Tentar novamente', style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  ],
                ),
              );
            }

          final rooms = snapshot.data![0] as List<DiscoverRoom>;
          final bundles = snapshot.data![1] as List<DiscoverBundle>;

          if (rooms.isEmpty && bundles.isEmpty) {
            return  Center(
              child: Text('Nada disponível no momento', style: TextStyle(color: theme.colorScheme.chatlistDiscoverNotingFoundTextColor),),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(
                left: 16, right: 16, bottom: _bottomButtonHeight + 24),
            children: [
              if (bundles.isNotEmpty) ...[
                ...bundles
                    .map((bundle) => _buildBundleCard(bundle, client, userId)),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
              ],
              Text(
                '👥 Grupos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.chatlistDiscoverTextColor,
                ),
              ),
              const SizedBox(height: 12),
              if (rooms.isEmpty)
                 Center(child: Text('Nenhum grupo disponível', style: TextStyle(color: theme.colorScheme.chatlistDiscoverNotingFoundTextColor))),

              ...rooms
                  .map((room) => _buildRoomTile(room, client, userId))
                  .toList(),
            ],
          );
        },
      ),
    );
  }

  // BUNDLE CARD

  Widget _buildBundleCard(DiscoverBundle bundle, Client client, String userId) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.chatlistDiscoverBundleTileBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bundle.name,
                  style: TextStyle(
                    color: theme.colorScheme
                        .chatlistDiscoverBundleTileGroupNameTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (bundle.isDraft)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Rascunho',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
              if (isAdmin)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme
                        .colorScheme.chatlistDiscoverBundleMenuItemTextColor,
                  ),
                  onSelected: (value) async {
                    if (value == 'publish') {
                      try {
                        await publishBundle(
                          client: client,
                          bundleId: bundle.id,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Bundle publicado!',
                                style: TextStyle(
                                    color: theme
                                        .colorScheme.normalSnackBarTextColor)),
                          ),
                        );

                        setState(() {
                          bundlesFuture = fetchBundles(client);
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Erro: $e',
                                  style: TextStyle(
                                      color: theme.colorScheme.error))),
                        );
                      }
                    }

                    if (value == 'edit') {
                      // FUTURO
                    }
                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Deletar bundle'),
                          content: const Text(
                              'Tem certeza que deseja deletar este bundle?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.error,
                        foregroundColor: theme
                            .colorScheme.chatlistDiscoverBundleButtonTextColor,
                      ),
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: Text('Deletar', style: TextStyle(
                                      color: theme.colorScheme.chatlistDiscoverBundleButtonTextColor)),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      try {
                        await deleteBundle(
                          client: client,
                          bundleId: bundle.id,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Bundle deletado!',
                              style: TextStyle(
                                color:
                                    theme.colorScheme.normalSnackBarTextColor,
                              ),
                            ),
                          ),
                        );

                        setState(() {
                          bundlesFuture = fetchBundles(client);
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erro: $e',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    if (bundle.isDraft)
                      PopupMenuItem(
                        value: 'publish',
                        child: Text(
                          'Publicar',
                          style: TextStyle(
                              color: theme.colorScheme
                                  .chatlistDiscoverBundleMenuItemTextColor),
                        ),
                      ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Editar',
                        style: TextStyle(
                            color: theme.colorScheme
                                .chatlistDiscoverBundleMenuItemTextColor),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Deletar',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${(bundle.price / 100).toStringAsFixed(2)}',
            style: TextStyle(
              color: theme.colorScheme
                  .chatlistDiscoverBundleTilePriceDescriptionTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text('Inclui ${bundle.rooms.length} grupos',
              style: TextStyle(
                  color: theme.colorScheme
                      .chatlistDiscoverBundleTileDescriptionTextColor)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  _showBundleDetails(context, bundle);
                },
                child: Text(
                  'Mais detalhes >',
                  style: TextStyle(
                    color: theme.colorScheme
                        .chatlistDiscoverBundleTileDescriptionTextColor,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.chatlistDiscoverBundleAccessButtonColor,
                ),
                onPressed: () async {
                  final approved = await _showFakePayment(context, bundle.price);
                  if (!approved) return;

                  try {
                    for (final keyword in bundle.keywords) {
                      await inviteToRoom(
                        client: client,
                        keyword: keyword,
                        userId: userId,
                      );
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bundle desbloqueado!', style: TextStyle(color: theme.colorScheme.normalSnackBarTextColor),)),
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao entrar nos grupos: ${e.toString()}', style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    );
                  }
                },
                child: Text(
                  'Pagar',
                  style: TextStyle(
                      color: theme
                          .colorScheme.chatlistDiscoverBundleButtonTextColor),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // ROOM TILE

  Widget _buildRoomTile(DiscoverRoom room, Client client, String userId) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.chatlistDiscoverRoomTileBackgroundColor,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            room.name,
            style: TextStyle(
              color:
                  theme.colorScheme.chatlistDiscoverRoomTileGroupNameTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.accessType == RoomAccessType.paid
                    ? 'Premium • R\$ ${(room.price / 100).toStringAsFixed(2)}'
                    : 'Entrada livre',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme
                      .chatlistDiscoverRoomTilePriceDescriptionTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: theme.colorScheme
                        .chatlistDiscoverRoomTilePriceDescriptionTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${room.memberCount} participantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme
                          .chatlistDiscoverRoomTilePriceDescriptionTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  theme.colorScheme.chatlistDiscoverRoomAccessButtonColor,
            ),
            child: Text(
              room.accessType == RoomAccessType.free ? 'Entrar' : 'Desbloquear',
              style: TextStyle(
                color: theme.colorScheme.chatlistDiscoverRoomButtonTextColor,
              ),
            ),
            onPressed: () async {
  try {
    if (room.accessType == RoomAccessType.paid) {
      final approved = await _showFakePayment(context, room.price);
      if (!approved) return;
    }

    await inviteToRoom(
      client: client,
      keyword: room.keyword,
      userId: userId,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Entrou no grupo!', style: TextStyle(color: theme.colorScheme.normalSnackBarTextColor))),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao entrar: ${e.toString()}', style: TextStyle(color: theme.colorScheme.error)),
      ),
    );
  }
}
          ),
        ),
      ),
    );
  }

  Future<bool> _showFakePayment(BuildContext context, int price) async {
    final theme = Theme.of(context);
    final formatted = 'R\$ ${(price / 100).toStringAsFixed(2)}';

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Pagamento'),
            content: Text('Confirmar pagamento de $formatted ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  'Pagar',
                  style: TextStyle(
                    color:
                        theme.colorScheme.chatlistDiscoverRoomButtonTextColor,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showBundleDetails(
    BuildContext context,
    DiscoverBundle bundle,
  ) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '👥 Grupos incluídos',
          style: TextStyle(
            color: theme.colorScheme.chatlistDiscoverTextColor,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: bundle.rooms
                .map(
                  (room) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• ${room.name}',
                      style: TextStyle(
                        color: theme.colorScheme
                            .chatlistDiscoverBundleTileDescriptionTextColor,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
