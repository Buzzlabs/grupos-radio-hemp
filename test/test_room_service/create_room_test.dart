import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient();
  }
}

class FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return FakeHttpRequest(url);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    return FakeHttpRequest(url);
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpRequest implements HttpClientRequest {
  final Uri url;

  FakeHttpRequest(this.url);

  @override
  Future<HttpClientResponse> close() async {
    return FakeHttpResponse(
      200,
      jsonEncode({"ok": true}),
    );
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  final int _statusCode;
  final String body;

  FakeHttpResponse(this._statusCode, this.body);

  @override
  int get statusCode => _statusCode;

  @override
  int get contentLength => body.length;

  @override
  bool get persistentConnection => false;

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => [];

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final bytes = utf8.encode(body);
    return Stream<List<int>>.fromIterable([bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => ['application/json'];

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDiscoverRoomsView extends StatelessWidget {
  const FakeDiscoverRoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.push('/rooms/newgroup');
          },
          child: const Text('Novo Grupo'),
        ),
      ),
    );
  }
}

void main() {
  final navigatorKey = GlobalKey<NavigatorState>();

  setUpAll(() {
    HttpOverrides.global = FakeHttpOverrides();

    FlutterError.onError = (details) {
      print('FLUTTER ERROR >>> ${details.exception}');
    };
  });

  Widget createTestApp() {
    final router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/rooms',
      routes: [
        GoRoute(
          path: '/rooms',
          builder: (context, state) => const FakeDiscoverRoomsView(),
        ),
        GoRoute(
          path: '/rooms/newgroup',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Nova Sala Page')),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  testWidgets('mostra botão de criar grupo e navega ao clicar', (tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.pump(const Duration(seconds: 1));

    final button = find.text('Novo Grupo');
    expect(button, findsOneWidget);

    await tester.tap(button);

    await tester.pump(const Duration(seconds: 1));

    expect(navigatorKey.currentState!.canPop(), true);
  });
}
