import 'dart:convert';
import 'dart:typed_data';

import 'package:fluffychat/utils/price_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart' as sdk;

import 'package:fluffychat/pages/new_group/new_group_view.dart';
import 'package:fluffychat/utils/file_selector.dart';
import 'package:fluffychat/widgets/matrix.dart';

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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController keywordController = TextEditingController();
  final TextEditingController priceController =
      TextEditingController(text: '0');

  bool publicGroup = false;
  bool groupCanBeFound = false;

  bool keywordAlreadyExists = false;

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

    keywordController.addListener(() {
      if (keywordAlreadyExists) {
        setState(() => keywordAlreadyExists = false);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    keywordController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void setPublicGroup(bool b) =>
      setState(() => publicGroup = b);

  void setGroupCanBeFound(bool b) =>
      setState(() => groupCanBeFound = b);

  String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  void _validateForm() {
    if (nameController.text.trim().isEmpty) {
      throw Exception('Nome do grupo é obrigatório');
    }

    if (keywordController.text.trim().isEmpty) {
      throw Exception('Keyword é obrigatória');
    }

    if (_slugify(keywordController.text.trim()) !=
        keywordController.text.trim()) {
      throw Exception('Keyword inválida');
    }

    if (groupCanBeFound && !publicGroup) {
    final price = PriceUtils.parseToCents(priceController.text);

    if (price <= 0) {
      throw Exception(
        'Grupos privados visíveis precisam ter preço',
      );
    }
  }
  }

  Future<String> _createGroupViaModule() async {
    final client = Matrix.of(context).client;

    final res = await http.post(
      Uri.parse(
        '${client.homeserver}/_synapse/room_service/create',
      ),
      headers: {
        'Authorization': 'Bearer ${client.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "room_kind": "group",
        "name": nameController.text.trim(),
        "keyword": keywordController.text.trim(),
        "access_type": publicGroup ? "public" : "private",
        "visible": groupCanBeFound,
        "price": (groupCanBeFound && !publicGroup)
          ? PriceUtils.parseToCents(priceController.text)
          : 0,
      }),
    );

    if (res.statusCode == 409) {
      setState(() {
        keywordAlreadyExists = true;
        loading = false;
      });
      throw Exception('KEYWORD_ALREADY_EXISTS');
    }

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    return jsonDecode(res.body)['room_id'] as String;
  }

 void submitAction([_]) async {
  final client = Matrix.of(context).client;

  String? roomId;

  try {
    _validateForm();

    setState(() {
      loading = true;
      error = null;
      keywordAlreadyExists = false;
    });

    roomId = await _createGroupViaModule();

    if (!mounted) return;
    try {
      final avatarBytes = avatar;

      final avatarUrlLocal = avatarUrl ??= avatarBytes == null
          ? null
          : await client.uploadContent(avatarBytes);

      if (avatarUrlLocal != null) {
        await client.setRoomStateWithKey(
          roomId,
          'm.room.avatar',
          '',
          {
            'url': avatarUrlLocal.toString(),
          },
        );
      }
    } catch (avatarError, s) {
      sdk.Logs().d('Erro ao setar avatar', avatarError, s);
    }

    context.go('/rooms/$roomId/invite');

  } catch (e, s) {
    if (e.toString().contains('KEYWORD_ALREADY_EXISTS')) return;

    sdk.Logs().d('Unable to create group', e, s);

    setState(() {
      error = e;
      loading = false;
    });
  }
}

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

