import 'dart:convert';
import 'package:fluffychat/config/themes.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:matrix/matrix.dart';

class SelectableRoom {
  final String id;
  final String name;

  SelectableRoom({
    required this.id,
    required this.name,
  });
}

class CreateBundleController extends ChangeNotifier {
  CreateBundleController(this.client);

  final Client client;

  final nameController = TextEditingController();
  final priceController = TextEditingController();

  bool loading = false;
  String? error;
  

  List<SelectableRoom> selectedRooms = [];

  /// ============================
  /// DISCOVER + SELECT ROOMS
  /// ============================
  Future<void> selectRooms(BuildContext context) async {
    try {
      loading = true;
      notifyListeners();

      final response = await client.httpClient.get(
        Uri.parse(
          "${client.homeserver}/_synapse/room_service/discover",
        ),
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
          final theme = Theme.of(context);

          return AlertDialog(
            title: Text("Selecionar Salas", style: TextStyle(color: theme.colorScheme.newBundleSelectTextColor),),
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
                      final theme = Theme.of(context);
                      return CheckboxListTile(
                        value: isChecked,
                        fillColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return theme.colorScheme.newBundleCheckBoxFillColor;
                          }
                          return theme.colorScheme.newBundleCheckBoxFillColor;
                        }),
                        checkColor:
                            theme.colorScheme.newBundleCheckBoxCheckColor,
                        side: MaterialStateBorderSide.resolveWith((states) {
                          return BorderSide(
                            color: theme.colorScheme.newBundleCheckBoxSideColor,
                            width: 1.5,
                          );
                        }),
                        title: Text(name, style: TextStyle(color: theme.colorScheme.newBundleSelectNameTextColor),),
                        subtitle: Text(roomId, style: TextStyle(color: theme.colorScheme.newBundleSelectRoomidTextColor),),
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
                    .map<SelectableRoom>(
                      (room) => SelectableRoom(
                        id: room["room_id"],
                        name: room["name"] ?? "Sem nome",
                      ),
                    )
                    .toList();

                notifyListeners();
                Navigator.pop(context);
              },
                child: Text("Confirmar", style: TextStyle(color: theme.colorScheme.newBundleButtonTextColor),),
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

  void removeRoom(SelectableRoom room) {
    selectedRooms.remove(room);
    notifyListeners();
  }

  /// ============================
  /// SUBMIT
  /// ============================
  Future<void> submit(BuildContext context) async {
  if (loading) return;

  final name = nameController.text.trim();
  final priceText = priceController.text.trim();

  if (name.isEmpty) {
    error = "Nome do bundle é obrigatório";
    notifyListeners();
    return;
  }

  if (priceText.isEmpty) {
    error = "Preço é obrigatório";
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
    final response = await client.httpClient.post(
      Uri.parse("${client.homeserver}/_synapse/bundles/create"),
      headers: {
        "Authorization": "Bearer ${client.accessToken}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "bundle_name": name,
        "price": price*100,
        "rooms": selectedRooms.map((r) => r.id).toList(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Erro ao criar bundle: ${response.body}");
    }

    nameController.clear();
    priceController.clear();
    selectedRooms.clear();

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
