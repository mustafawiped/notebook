import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebook/model/detail_page_args.dart';
import 'package:notebook/pages/drafts/drafts_page.dart';
import 'package:notebook/pages/home/home_page.dart';
import 'package:notebook/pages/note_add/add_note_page.dart';
import 'package:notebook/pages/detail/detail_page.dart';
import 'package:notebook/utils/constants/app_colors.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    errorBuilder: (context, state) => errorScreen(state, context),
    observers: [BotToastNavigatorObserver()],
    routes: [
      // home route
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // add a new note route
      GoRoute(
        path: '/addNote',
        name: 'addNote',
        builder: (context, state) => const AddNotePage(),
      ),

      // detail route
      GoRoute(
        path: '/noteDetail',
        name: 'noteDetail',
        builder: (context, state) {
          return DetailPage(args: state.extra as DetailArgs);
        },
      ),

      // draft route
      GoRoute(
        path: '/drafts',
        name: 'drafts',
        builder: (context, state) => DraftsPage(),
      ),
    ],
  );
});

Widget errorScreen(GoRouterState state, BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Page not found",
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.error.toString(),
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Go Home"),
          ),
        ],
      ),
    ),
  );
}

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