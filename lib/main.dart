import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook/core/router/app_router.dart';
import 'package:notebook/core/services/notification_service.dart';
import 'package:notebook/utils/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      builder: BotToastInit(),
      color: AppColors.background,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.accent,
          onSurface: AppColors.text,
        ),

        scaffoldBackgroundColor: AppColors.background,

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppColors.accent),
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.text),
          bodyMedium: TextStyle(color: AppColors.text),
          bodySmall: TextStyle(color: AppColors.secondaryText),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
