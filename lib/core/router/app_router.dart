import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebook/pages/home/home_page.dart';
import 'package:notebook/pages/note_add/add_note_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    observers: [BotToastNavigatorObserver()],
    routes: [
      // Home Page Route
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Add a new note Route
      GoRoute(
        path: '/addNote',
        name: 'addNote',
        builder: (context, state) => const AddNotePage(),
      ),
    ],
  );
});

      //  GoRoute(
      //   path: '/detail/:id',                   -- parametreli route
      //   name: 'detail',
      //   builder: (context, state) {
      //     final id = state.pathParameters['id']!;
      //     return DetailPage(id: id);
      //   },
      // ),

      /*
        // Gönderirken
        context.push('/detail', extra: myNote);

        // Route tanımı
        GoRoute(
          path: '/detail',
          builder: (context, state) {
            final note = state.extra as Note;
            return DetailPage(note: note);
          },
        )
      */