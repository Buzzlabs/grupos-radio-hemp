import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class BundleRoom {
  final String id;
  final String name;

  BundleRoom({required this.id, required this.name});
}

class BundleFormController extends ChangeNotifier {
  BundleFormController.create(this.client);

  BundleFormController.edit(this.client, this.bundleId) {
    isEdit = true;
    loadBundle();
  }

  final Client client;

  bool isEdit = false;
  String? bundleId;

  final nameController = TextEditingController();
  final priceController = TextEditingController();

  bool loading = false;
  String? error;

  List<BundleRoom> selectedRooms = [];

  /// LOAD BUNDLE
  Future<void> loadBundle() async {
    if (bundleId == null) return;

    try {
      loading = true;
      notifyListeners();

      final bundleResponse = await client.httpClient.get(
        Uri.parse("${client.homeserver}/_synapse/bundles/list"),
        headers: {
          "Authorization": "Bearer ${client.accessToken}",
          "Content-Type": "application/json",
        },
      );

      if (bundleResponse.statusCode != 200) {
        throw Exception("Erro ao carregar bundles");
      }

      final bundleData = jsonDecode(bundleResponse.body);
      final List bundles = bundleData["bundles"];

      final bundle = bundles.firstWhere(
        (b) => b["bundle_id"] == bundleId,
        orElse: () => null,
      );

      if (bundle == null) {
        throw Exception("Bundle não encontrado");
      }

      nameController.text = bundle["bundle_name"] ?? "";

      final price = bundle["price"] ?? 0;
      priceController.text = (price ~/ 100).toString();

      final roomIds = List<String>.from(bundle["rooms"] ?? []);

      final discoverResponse = await client.httpClient.get(
        Uri.parse("${client.homeserver}/_synapse/room_service/discover"),
        headers: {
          "Authorization": "Bearer ${client.accessToken}",
          "Content-Type": "application/json",
        },
      );

      final discoverData = jsonDecode(discoverResponse.body);
      final List discoverRooms = discoverData["rooms"];

      selectedRooms = discoverRooms
          .where((room) => roomIds.contains(room["room_id"]))
          .map((room) => BundleRoom(
                id: room["room_id"],
                name: room["name"] ?? "Sem nome",
              ))
          .toList();
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  /// SELECT ROOMS
  Future<void> selectRooms(BuildContext context) async {
    try {
      loading = true;
      notifyListeners();

      final response = await client.httpClient.get(
        Uri.parse("${client.homeserver}/_synapse/room_service/discover"),
        headers: {
          "Authorization": "Bearer ${client.accessToken}",
          "Content-Type": "application/json",
        },
      );

      loading = false;
      notifyListeners();

      if (response.statusCode != 200) {
        throw Exception("Erro ao buscar salas");
      }

      final data = jsonDecode(response.body);
      final List rooms = data["rooms"];

      final selectedIds = selectedRooms.map((r) => r.id).toSet();

      await showDialog(
        context: context,
        builder: (context) {
          final tempSelected = {...selectedIds};

          return AlertDialog(
            title: const Text("Selecionar Salas"),
            content: SizedBox(
              width: 400,
              child: ListView(
                shrinkWrap: true,
                children: rooms.map((room) {
                  final roomId = room["room_id"];
                  final name = room["name"] ?? "Sem nome";

                  return StatefulBuilder(
                    builder: (context, setState) {
                      final isChecked = tempSelected.contains(roomId);

                      return CheckboxListTile(
                        value: isChecked,
                        title: Text(name),
                        subtitle: Text(roomId),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              tempSelected.add(roomId);
                            } else {
                              tempSelected.remove(roomId);
                            }
                          });
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  selectedRooms = rooms
                      .where((room) => tempSelected.contains(room["room_id"]))
                      .map((room) => BundleRoom(
                            id: room["room_id"],
                            name: room["name"] ?? "Sem nome",
                          ))
                      .toList();

                  notifyListeners();
                  Navigator.pop(context);
                },
                child: const Text("Confirmar"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  void removeRoom(BundleRoom room) {
    selectedRooms.remove(room);
    notifyListeners();
  }

  /// SUBMIT
  Future<void> submit(BuildContext context) async {
    if (loading) return;

    final name = nameController.text.trim();
    final priceText = priceController.text.trim();

    if (name.isEmpty) {
      error = "Nome do bundle é obrigatório";
      notifyListeners();
      return;
    }

    final price = int.tryParse(priceText);
    if (price == null) {
      error = "Preço inválido";
      notifyListeners();
      return;
    }

    error = null;
    loading = true;
    notifyListeners();

    try {
      final endpoint =
          isEdit ? "/_synapse/bundles/update" : "/_synapse/bundles/create";

      final body = {
        "bundle_name": name,
        "price": price * 100,
        "rooms": selectedRooms.map((r) => r.id).toList(),
      };

      if (isEdit) {
        body["bundle_id"] = bundleId!;
      }

      final response = await client.httpClient.post(
        Uri.parse("${client.homeserver}$endpoint"),
        headers: {
          "Authorization": "Bearer ${client.accessToken}",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.body);
      }

      Navigator.pop(context);
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }
}