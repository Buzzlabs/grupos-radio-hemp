import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart' as sdk;

import 'package:fluffychat/pages/new_group/new_group_view.dart';
import 'package:fluffychat/utils/file_selector.dart';
import 'package:fluffychat/widgets/matrix.dart';

/// ============================
/// ENUM
/// ============================
enum CreateGroupType { group, space }

class NewGroup extends StatefulWidget {
  final CreateGroupType createGroupType;

  const NewGroup({
    this.createGroupType = CreateGroupType.group,
    super.key,
  });

  @override
  NewGroupController createState() => NewGroupController();
}

class NewGroupController extends State<NewGroup> {
  /// Nome do grupo
  final TextEditingController nameController = TextEditingController();

  /// Keyword (somente se visível)
  final TextEditingController keywordController = TextEditingController();

  /// Preço — somente se visível + privado
  final TextEditingController priceController =
      TextEditingController(text: '0');

  bool publicGroup = false;
  bool groupCanBeFound = false;

  Uint8List? avatar;
  Uri? avatarUrl;

  Object? error;
  bool loading = false;

  CreateGroupType get createGroupType =>
      _createGroupType ?? widget.createGroupType;

  CreateGroupType? _createGroupType;

  @override
  void initState() {
    super.initState();

    // /// Auto-sugere keyword baseada no nome
    // nameController.addListener(() {
    //   if (keywordController.text.isEmpty) {
    //     keywordController.text = _slugify(nameController.text);
    //   }
    // });
  }

  @override
  void dispose() {
    nameController.dispose();
    keywordController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void setCreateGroupType(Set<CreateGroupType> b) =>
      setState(() => _createGroupType = b.single);

  void setPublicGroup(bool b) =>
      setState(() => publicGroup = b);

  void setGroupCanBeFound(bool b) =>
      setState(() => groupCanBeFound = b);

  /// ============================
  /// HELPERS
  /// ============================
  String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  int _calculatePrice() {
    if (!groupCanBeFound || publicGroup) return 0;

    final text = priceController.text
        .replaceAll(',', '.')
        .trim();

    final value = double.tryParse(text);
    if (value == null) return 0;

    return (value * 100).round();
  }


  /// ============================
  /// VALIDAÇÃO
  /// ============================
  void _validateForm() {
    if (nameController.text.trim().isEmpty) {
      throw Exception('Nome do grupo é obrigatório');
    }

    if (groupCanBeFound) {
      if (keywordController.text.trim().isEmpty) {
        throw Exception('Keyword é obrigatória para grupos visíveis');
      }

      if (_slugify(keywordController.text.trim()) !=
          keywordController.text.trim()) {
        throw Exception('Keyword inválida');
      }

      if (!publicGroup) {
        final price = int.tryParse(priceController.text) ?? 0;
        if (price <= 0) {
          throw Exception(
            'Grupos privados visíveis precisam ter preço',
          );
        }
      }
    }
  }

  /// ============================
  /// BACKEND
  /// ============================
  Future<String> _createGroupViaModule() async {
    final client = Matrix.of(context).client;

    final body = {
      "room_kind": "group",
      "name": nameController.text.trim(),
      "keyword": keywordController.text.trim(),
      "access_type": publicGroup ? "free" : "paid",
      "visible": true,
      "price": _calculatePrice(),
    };

    final res = await http.post(
      Uri.parse(
        '${client.homeserver}/_synapse/room_service/create',
      ),
      headers: {
        'Authorization': 'Bearer ${client.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    return jsonDecode(res.body)['room_id'] as String;
  }

  Future<String> _createNormalGroup() async {
    final client = Matrix.of(context).client;

    return await client.createRoom(
      name: nameController.text.trim(),
      visibility: publicGroup
          ? sdk.Visibility.public
          : sdk.Visibility.private,
      preset: sdk.CreateRoomPreset.privateChat,
    );
  }

  /// ============================
  /// SUBMIT
  /// ============================
  void submitAction([_]) async {
    final client = Matrix.of(context).client;

    try {
      _validateForm();

      setState(() {
        loading = true;
        error = null;
      });

      final avatarBytes = avatar;
      avatarUrl ??= avatarBytes == null
          ? null
          : await client.uploadContent(avatarBytes);

      if (!mounted) return;

      final roomId = groupCanBeFound
          ? await _createGroupViaModule()
          : await _createNormalGroup();

      if (!mounted) return;
      context.go('/rooms/$roomId/invite');
    } catch (e, s) {
      sdk.Logs().d('Unable to create group', e, s);
      setState(() {
        error = e;
        loading = false;
      });
    }
  }

  /// ============================
  /// AVATAR
  /// ============================
  void selectPhoto() async {
    final photo = await selectFiles(
      context,
      type: FileSelectorType.images,
      allowMultiple: false,
    );

    final bytes = await photo.singleOrNull?.readAsBytes();

    if (!mounted) return;

    setState(() {
      avatar = bytes;
      avatarUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) => NewGroupView(this);
}
