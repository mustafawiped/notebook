import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook/core/database/app_database.dart';

final addNoteViewModelProvider =
    ChangeNotifierProvider.autoDispose<AddNotePageViewModel>(
      (ref) => AddNotePageViewModel(ref),
    );

class AddNotePageViewModel extends ChangeNotifier {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  final Ref ref;
  late DateTime compDate;
  List<String> selectedTags = [];

  AddNotePageViewModel(this.ref);

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<String> saveNote() async {
    try {
      String title = titleController.text.trim(),
          desc = descController.text.trim();

      if (title.length < 3) return "Başlık en az 3 karakter olabilir.";

      final id = await ref
          .read(databaseProvider)
          .insertNote(
            NotesCompanion(
              title: Value(title),
              content: Value(desc),
              tag: Value(""),
              date: Value(DateTime.now()),
            ),
          );

      return id > 0
          ? "success"
          : "Veri tabanına eklerken bir sorunla karşılaşıldı.";
    } catch (e) {
      if (kDebugMode) {
        print("AddNotePageView | saveNote | Try-Catch Error | Error: $e");
      }
      return "Bir şeyler ters gitti, not eklenemedi.";
    }
  }
}
