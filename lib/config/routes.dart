import 'dart:async';

import 'package:fluffychat/pages/login/auto_login.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/archive/archive.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pages/chat_access_settings/chat_access_settings_controller.dart';
import 'package:fluffychat/pages/chat_details/chat_details.dart';
import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/pages/chat_members/chat_members.dart';
import 'package:fluffychat/pages/chat_permissions_settings/chat_permissions_settings.dart';
import 'package:fluffychat/pages/chat_search/chat_search_page.dart';
import 'package:fluffychat/pages/device_settings/device_settings.dart';
import 'package:fluffychat/pages/invitation_selection/invitation_selection.dart';
import 'package:fluffychat/pages/extensions/extensions.dart';
import 'package:fluffychat/pages/login/login.dart';
import 'package:fluffychat/pages/register/register.dart';
import 'package:fluffychat/pages/settings/settings.dart';
import 'package:fluffychat/pages/settings_emotes/settings_emotes.dart';
import 'package:fluffychat/pages/settings_multiple_emotes/settings_multiple_emotes.dart';
import 'package:fluffychat/widgets/config_viewer.dart';
import 'package:fluffychat/widgets/layouts/empty_page.dart';
import 'package:fluffychat/widgets/layouts/two_column_layout.dart';
import 'package:fluffychat/widgets/log_view.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:fluffychat/widgets/share_scaffold_dialog.dart';
import 'package:fluffychat/guard/guard.dart';
import 'package:fluffychat/pages/teste.dart';
import 'package:fluffychat/pages/screen_video.dart';
import 'package:fluffychat/pages/lives_data.dart';
import 'package:fluffychat/widgets/streams_widget.dart';

abstract class AppRoutes {
  static FutureOr<String?> loggedInRedirect(
    BuildContext context,
    GoRouterState state,
  ) =>
      Matrix.of(context).widget.clients.any((client) => client.isLogged())
          ? '/rooms'
          : null;

  static FutureOr<String?> loggedOutRedirect(
    BuildContext context,
    GoRouterState state,
  ) =>
      Matrix.of(context).widget.clients.any((client) => client.isLogged())
          ? null
          : '/homeserver';

  AppRoutes();

  static final List<RouteBase> routes = [
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final isLogged = Matrix.of(context)
            .widget
            .clients
            .any((client) => client.isLogged());
        final path = state.fullPath;

        if (path == '/login' || path == '/register') return null;

        return isLogged ? '/rooms' : '/homeserver';
      },
    ),
    GoRoute(
      path: '/homeserver',
      pageBuilder: (context, state) => defaultPageBuilder(
        context,
        state,
        const AutoLoginScreen(),
      ),
    ),
    GoRoute(
      path: '/teste',
      pageBuilder: (context, state) => defaultPageBuilder(
        context,
        state,
        const Teste(),
      ),
    ),
    // Definindo a rota
    GoRoute(
      name: 'screen_video',
      path: '/screen_video/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;

        // Tenta buscar na lista global primeiro
        final live = getLiveById(id);

        if (live != null) {
          return ScreenVideo(live: live);
        }

        // Se não tiver na lista, busca do backend
        return Scaffold(
          appBar: AppBar(title: const Text('Carregando live')),
          body: FutureBuilder<LiveShow?>(
            future: fetchLiveById(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                return const Center(child: Text('Live não encontrada'));
              } else {
                return ScreenVideo(live: snapshot.data!);
              }
            },
          ),
        );
      },
    ),

    GoRoute(
      path: '/login',
      redirect: loggedInRedirect,
      builder: (context, state) {
        final extra = state.extra;
        if (extra == null || extra is! Client) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/homeserver?from=login');
          });
          return const SizedBox.shrink();
        }
        final client = extra;
        return Login(client: client);
      },
    ),
    GoRoute(
      path: '/register',
      redirect: loggedInRedirect,
      builder: (context, state) {
        final extra = state.extra;
        if (extra == null || extra is! Client) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/homeserver?from=register');
          });
          return const SizedBox.shrink();
        }
        final client = extra;
        return Register(client: client);
      },
    ),
    GoRoute(
      path: '/logs',
      pageBuilder: (context, state) => defaultPageBuilder(
        context,
        state,
        const LogViewer(),
      ),
    ),
    GoRoute(
      path: '/configs',
      pageBuilder: (context, state) => defaultPageBuilder(
        context,
        state,
        const ConfigViewer(),
      ),
    ),
    ShellRoute(
      // Never use a transition on the shell route. Changing the PageBuilder
      // here based on a MediaQuery causes the child to briefly be rendered
      // twice with the same GlobalKey, blowing up the rendering.
      pageBuilder: (context, state, child) => noTransitionPageBuilder(
        context,
        state,
        FluffyThemes.isColumnMode(context) &&
                state.fullPath?.startsWith('/rooms/settings') == false
            ? TwoColumnLayout(
                mainView: ChatList(
                  activeChat: state.pathParameters['roomid'],
                  displayNavigationRail:
                      state.path?.startsWith('/rooms/settings') != true,
                ),
                sideView: child,
              )
            : child,
      ),
      routes: [
        GoRoute(
          path: '/rooms',
          redirect: loggedOutRedirect,
          pageBuilder: (context, state) => defaultPageBuilder(
            context,
            state,
            FluffyThemes.isColumnMode(context)
                ? const EmptyPage()
                : ChatList(
                    activeChat: state.pathParameters['roomid'],
                  ),
          ),
          routes: [
            GoRoute(
              path: 'archive',
              pageBuilder: (context, state) => defaultPageBuilder(
                context,
                state,
                const Archive(),
              ),
              routes: [
                GoRoute(
                  path: ':roomid',
                  pageBuilder: (context, state) => defaultPageBuilder(
                    context,
                    state,
                    ChatPage(
                      roomId: state.pathParameters['roomid']!,
                      eventId: state.uri.queryParameters['event'],
                    ),
                  ),
                  redirect: loggedOutRedirect,
                ),
              ],
              redirect: loggedOutRedirect,
            ),
            // GoRoute(
            //   path: 'newprivatechat',
            //   pageBuilder: (context, state) => defaultPageBuilder(
            //     context,
            //     state,
            //     const NewPrivateChat(),
            //   ),
            //   redirect: loggedOutRedirect,
            // ),
            // GoRoute(
            //   path: 'newgroup',
            //   pageBuilder: (context, state) => defaultPageBuilder(
            //     context,
            //     state,
            //     const NewGroup(),
            //   ),
            //   redirect: loggedOutRedirect,
            // ),
            // GoRoute(
            //   path: 'newspace',
            //   pageBuilder: (context, state) => defaultPageBuilder(
            //     context,
            //     state,
            //     const NewGroup(createGroupType: CreateGroupType.space),
            //   ),
            //   redirect: loggedOutRedirect,
            // ),
            ShellRoute(
              pageBuilder: (context, state, child) => defaultPageBuilder(
                context,
                state,
                FluffyThemes.isColumnMode(context)
                    ? TwoColumnLayout(
                        mainView: Settings(key: state.pageKey),
                        sideView: child,
                      )
                    : child,
              ),
              routes: [
                GoRoute(
                  path: 'settings',
                  pageBuilder: (context, state) => defaultPageBuilder(
                    context,
                    state,
                    FluffyThemes.isColumnMode(context)
                        ? const EmptyPage()
                        : const Settings(),
                  ),
                  routes: [
                    // GoRoute(
                    //   path: 'notifications',
                    //   pageBuilder: (context, state) => defaultPageBuilder(
                    //     context,
                    //     state,
                    //     const SettingsNotifications(),
                    //   ),
                    //   redirect: loggedOutRedirect,
                    // ),
                    // GoRoute(
                    //   path: 'style',
                    //   pageBuilder: (context, state) => defaultPageBuilder(
                    //     context,
                    //     state,
                    //     const SettingsStyle(),
                    //   ),
                    //   redirect: loggedOutRedirect,
                    // ),
                    GoRoute(
                      path: 'devices',
                      pageBuilder: (context, state) => defaultPageBuilder(
                        context,
                        state,
                        const DevicesSettings(),
                      ),
                      redirect: loggedOutRedirect,
                    ),
                    // GoRoute(
                    //   path: 'chat',
                    //   pageBuilder: (context, state) => defaultPageBuilder(
                    //     context,
                    //     state,
                    //     const SettingsChat(),
                    //   ),
                    //   routes: [
                    //     GoRoute(
                    //       path: 'emotes',
                    //       pageBuilder: (context, state) => defaultPageBuilder(
                    //         context,
                    //         state,
                    //         const EmotesSettings(),
                    //       ),
                    //     ),
                    //   ],
                    //   redirect: loggedOutRedirect,
                    // ),
                    // GoRoute(
                    //   path: 'addaccount',
                    //   redirect: loggedOutRedirect,
                    //   pageBuilder: (context, state) => defaultPageBuilder(
                    //     context,
                    //     state,
                    //     const HomeserverPicker(addMultiAccount: true),
                    //   ),
                    //   routes: [
                    //     GoRoute(
                    //       path: 'login',
                    //       pageBuilder: (context, state) => defaultPageBuilder(
                    //         context,
                    //         state,
                    //         Login(client: state.extra as Client),
                    //       ),
                    //       redirect: loggedOutRedirect,
                    //     ),
                    //   ],
                    // ),
                    // GoRoute(
                    //   path: 'homeserver',
                    //   pageBuilder: (context, state) {
                    //     return defaultPageBuilder(
                    //       context,
                    //       state,
                    //       const SettingsHomeserver(),
                    //     );
                    //   },
                    //   redirect: loggedOutRedirect,
                    // ),
                    // GoRoute(
                    //   path: 'security',
                    //   redirect: loggedOutRedirect,
                    //   pageBuilder: (context, state) => defaultPageBuilder(
                    //     context,
                    //     state,
                    //     const SettingsSecurity(),
                    //   ),
                    //   routes: [
                    //     GoRoute(
                    //       path: 'password',
                    //       pageBuilder: (context, state) {
                    //         return defaultPageBuilder(
                    //           context,
                    //           state,
                    //           const SettingsPassword(),
                    //         );
                    //       },
                    //       redirect: loggedOutRedirect,
                    //     ),
                    //     GoRoute(
                    //       path: 'ignorelist',
                    //       pageBuilder: (context, state) {
                    //         return defaultPageBuilder(
                    //           context,
                    //           state,
                    //           SettingsIgnoreList(
                    //             initialUserId: state.extra?.toString(),
                    //           ),
                    //         );
                    //       },
                    //       redirect: loggedOutRedirect,
                    //     ),
                    //     GoRoute(
                    //       path: '3pid',
                    //       pageBuilder: (context, state) => defaultPageBuilder(
                    //         context,
                    //         state,
                    //         const Settings3Pid(),
                    //       ),
                    //       redirect: loggedOutRedirect,
                    //     ),
                    //   ],
                    // ),
                  ],
                  redirect: loggedOutRedirect,
                ),
              ],
            ),
            GoRoute(
              path: ':roomid',
              pageBuilder: (context, state) {
                final body = state.uri.queryParameters['body'];
                var shareItems = state.extra is List<ShareItem>
                    ? state.extra as List<ShareItem>
                    : null;
                if (body != null && body.isNotEmpty) {
                  shareItems ??= [];
                  shareItems.add(TextShareItem(body));
                }
                return defaultPageBuilder(
                  context,
                  state,
                  ChatPage(
                    roomId: state.pathParameters['roomid']!,
                    shareItems: shareItems,
                    eventId: state.uri.queryParameters['event'],
                  ),
                );
              },
              redirect: loggedOutRedirect,
              routes: [
                GoRoute(
                  path: 'search',
                  pageBuilder: (context, state) => defaultPageBuilder(
                    context,
                    state,
                    ChatSearchPage(
                      roomId: state.pathParameters['roomid']!,
                    ),
                  ),
                  redirect: loggedOutRedirect,
                ),
                // GoRoute(
                //   path: 'encryption',
                //   pageBuilder: (context, state) => defaultPageBuilder(
                //     context,
                //     state,
                //     const ChatEncryptionSettings(),
                //   ),
                //   redirect: loggedOutRedirect,
                // ),
                GoRoute(
                  path: 'invite',
                  pageBuilder: (context, state) => defaultPageBuilder(
                    context,
                    state,
                    InvitationSelection(
                      roomId: state.pathParameters['roomid']!,
                    ),
                  ),
                  redirect: loggedOutRedirect,
                ),
                GoRoute(
                  path: 'details',
                  pageBuilder: (context, state) => defaultPageBuilder(
                    context,
                    state,
                    ChatDetails(
                      roomId: state.pathParameters['roomid']!,
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'access',
                      pageBuilder: (context, state) => defaultPageBuilder(
                        context,
                        state,
                        ChatAccessSettings(
                          roomId: state.pathParameters['roomid']!,
                        ),
                      ),
                      redirect: loggedOutRedirect,
                    ),
                    GoRoute(
                      path: 'members',
                      pageBuilder: (context, state) => defaultPageBuilder(
                        context,
                        state,
                        ChatMembersPage(
                          roomId: state.pathParameters['roomid']!,
                        ),
                      ),
                      redirect: loggedOutRedirect,
                    ),
                    GoRoute(
                      path: 'permissions',
                      pageBuilder: (context, state) => defaultPageBuilder(
                        context,
                        state,
                        const ChatPermissionsSettings(),
                      ),
                      redirect: loggedOutRedirect,
                    ),
                    GoRoute(
                      path: 'invite',
                      pageBuilder: (context, state) => defaultPageBuilder(
                        context,
                        state,
                        InvitationSelection(
                          roomId: state.pathParameters['roomid']!,
                        ),
                      ),
                      redirect: loggedOutRedirect,
                    ),
                    GoRoute(
                      path: 'multiple_emotes',
                      pageBuilder: (context, state) => defaultPageBuilder(
                        context,
                        state,
                        const MultipleEmotesSettings(),
                      ),
                      redirect: loggedOutRedirect,
                    ),
                    GoRoute(
                      path: 'emotes',
                      pageBuilder: (context, state) => defaultPageBuilder(
                        context,
                        state,
                        const EmotesSettings(),
                      ),
                      redirect: loggedOutRedirect,
                    ),
                    GoRoute(
                      path: 'emotes/:state_key',
                      pageBuilder: (context, state) => defaultPageBuilder(
                        context,
                        state,
                        const EmotesSettings(),
                      ),
                      redirect: loggedOutRedirect,
                    ),
                    GoRoute(
                      path: 'extensions',
                      pageBuilder: (context, state) => defaultPageBuilder(
                        context,
                        state,
                        Extensions(
                          roomId: state.pathParameters['roomid']!,
                        ),
                      ),
                      redirect: (context, state) => powerLevelRedirect(
                        context,
                        state,
                        minPowerLevel: 100,
                        fallbackRoute:
                            '/rooms/${state.pathParameters['roomid']}',
                      ),
                    ),
                  ],
                  redirect: loggedOutRedirect,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  static Page noTransitionPageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) =>
      NoTransitionPage(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        child: child,
      );

  static Page defaultPageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) =>
      FluffyThemes.isColumnMode(context)
          ? noTransitionPageBuilder(context, state, child)
          : MaterialPage(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: child,
            );
}
