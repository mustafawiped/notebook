import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook/core/database/app_database.dart';
import 'package:notebook/model/detail_page_args.dart';

final addNoteViewModelProvider =
    ChangeNotifierProvider.autoDispose<AddNotePageViewModel>(
      (ref) => AddNotePageViewModel(ref),
    );

class AddNotePageViewModel extends ChangeNotifier {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  final Ref ref;
  DateTime? compDate;
  List<String> selectedTags = [];

  AddNotePageViewModel(this.ref);

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  String? _validateNote() {
    if (titleController.text.trim().length < 3) {
      return "Title can be at least 3 characters long.";
    }
    if (compDate == null) {
      return "Please select your preferred completion time.";
    }
    return null;
  }

  Future<String> saveNote(DetailArgs? args) async {
    final error = _validateNote();
    if (error != null) return error;

    try {
      String title = titleController.text.trim(),
          content = descController.text.trim(),
          tag = selectedTags.join('|');
      DateTime date = compDate!;

      int id = 0;

      if (args != null) {
        if (args.mode == DetailMode.draft) {
          bool state = await ref
              .read(databaseProvider)
              .updateDraft(
                DraftsCompanion(
                  id: Value(args.draft!.id),
                  title: Value(title),
                  content: Value(content),
                  tag: Value(tag),
                  date: Value(date),
                  lastModified: Value(DateTime.now()),
                ),
              );
          id = state ? 1 : 0;
        } else {
          bool state = await ref
              .read(databaseProvider)
              .updateNote(
                NotesCompanion(
                  id: Value(args.note!.id),
                  title: Value(title),
                  content: Value(content),
                  tag: Value(tag),
                  date: Value(date),
                ),
              );
          id = state ? 1 : 0;
        }
      } else {
        id = await ref
            .read(databaseProvider)
            .insertNote(
              NotesCompanion(
                title: Value(title),
                content: Value(content),
                tag: Value(tag),
                date: Value(date),
              ),
            );
      }

      return id > 0
          ? "success"
          : "An error occurred while adding to the database.";
    } catch (e) {
      return "Something went wrong, the note could not be saved.";
    }
  }

  Future<String> draftNote() async {
    final error = _validateNote();
    if (error != null) return error;

    try {
      final id = await ref
          .read(databaseProvider)
          .insertDraft(
            DraftsCompanion(
              title: Value(titleController.text.trim()),
              content: Value(descController.text.trim()),
              tag: Value(selectedTags.join('|')),
              date: Value(compDate!),
              lastModified: Value(DateTime.now()),
            ),
          );
      return id > 0
          ? "success"
          : "An error occurred while adding to the database.";
    } catch (e) {
      return "Something went wrong, the draft could not be saved.";
    }
  }
}
