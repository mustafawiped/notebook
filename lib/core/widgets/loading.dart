// lib/core/widgets/loading_overlay.dart

import 'package:flutter/material.dart';
import 'package:notebook/utils/constants/app_colors.dart';

class LoadingOverlay {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Container(
          color: AppColors.background.withValues(alpha: 0.4),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
