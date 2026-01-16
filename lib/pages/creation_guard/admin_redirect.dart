import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../creation_guard/admin_service.dart';

Future<String?> adminRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  final matrix = Matrix.of(context);
  final client = matrix.client;

  if (client.accessToken == null || client.homeserver == null) {
    return '/rooms'; 
  }

  final adminService = AdminService(
    client.homeserver!.toString(),
    client.accessToken!,
  );

  final isAdmin = await adminService.isAdmin();

  if (!isAdmin) {
    return '/rooms';
  }

  return null;
}
