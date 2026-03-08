import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook/core/database/app_database.dart';
import 'package:notebook/core/services/notification_service.dart';
import 'package:notebook/model/detail_page_args.dart';

final detailPageProvider =
    ChangeNotifierProvider.autoDispose<DetailPageViewModel>(
      (ref) => DetailPageViewModel(ref),
    );

class DetailPageViewModel extends ChangeNotifier {
  Ref ref;

  DetailPageViewModel(this.ref);

  Future<String> deleteData(DetailArgs args) async {
    try {
      int response;
      if (args.mode == DetailMode.note) {
        response = await ref.read(databaseProvider).deleteNote(args.note!.id);
        if (response > 0) {
          await NotificationService.cancelNoteNotifications(args.note!.id);
        }
      } else {
        response = await ref.read(databaseProvider).deleteDraft(args.draft!.id);
      }

      return response > 0
          ? "success"
          : "The note is not be deleted, pls try again.";
    } catch (e) {
      return "Something went wrong. Pls try again.";
    }
  }

  Future<String> addNotes(DetailArgs args) async {
    try {
      int noteInsertResponse = await ref
          .read(databaseProvider)
          .insertNote(
            NotesCompanion(
              title: Value(args.draft!.title),
              content: Value(args.draft!.content),
              date: Value(args.draft!.date),
              tag: Value(args.draft!.tag),
            ),
          );

      int removeResponse = await ref
          .read(databaseProvider)
          .deleteDraft(args.draft!.id);

      return noteInsertResponse > 0 && removeResponse > 0
          ? "success"
          : "The draft is not be added, pls try again.";
    } catch (e) {
      return "Something went wrong. Pls try again.";
    }
  }
}
