import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook/core/database/app_database.dart';

final noteDetailPageProvider = ChangeNotifierProvider<NoteDetailPageViewModel>(
  (ref) => NoteDetailPageViewModel(ref),
);

class NoteDetailPageViewModel extends ChangeNotifier {
  Ref ref;

  NoteDetailPageViewModel(this.ref);

  Future<String> deleteNote(int noteId) async {
    try {
      int response = await ref.read(databaseProvider).deleteNote(noteId);

      return response > 0
          ? "success"
          : "The note is not be deleted, pls try again.";
    } catch (e) {
      return "Something went wrong. Pls try again.";
    }
  }
}
