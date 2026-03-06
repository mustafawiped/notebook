import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notebook/core/database/app_database.dart';
import 'package:notebook/model/draft_group.dart';

final draftsPageViewProvider =
    ChangeNotifierProvider.autoDispose<DraftsPageViewModel>(
      (ref) => DraftsPageViewModel(ref),
    );

class DraftsPageViewModel extends ChangeNotifier {
  Ref ref;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<DraftGroup> _draftGroups = [];
  List<DraftGroup> get draftGroups => _draftGroups;

  bool refreshStatus = false;

  DraftsPageViewModel(this.ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDrafts();
    });
  }

  Future<void> loadDrafts() async {
    _isLoading = true;
    notifyListeners();

    final drafts = await ref.read(databaseProvider).getDrafts();
    _draftGroups = _groupDrafts(drafts);

    _isLoading = false;
    notifyListeners();
  }

  List<DraftGroup> _groupDrafts(List<Draft> notes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final todayNotes = <Draft>[];
    final tomorrowNotes = <Draft>[];
    final otherNotes = <Draft>[];

    for (final note in notes) {
      final noteDay = DateTime(note.date.year, note.date.month, note.date.day);
      if (noteDay == today) {
        todayNotes.add(note);
      } else if (noteDay == tomorrow) {
        tomorrowNotes.add(note);
      } else if (noteDay.isAfter(today)) {
        otherNotes.add(note);
      }
    }

    final groups = <DraftGroup>[];

    if (todayNotes.isNotEmpty) {
      todayNotes.sort((a, b) => a.date.compareTo(b.date));
      groups.add(DraftGroup(title: "Today's drafts", notes: todayNotes));
    }

    if (tomorrowNotes.isNotEmpty) {
      tomorrowNotes.sort((a, b) => a.date.compareTo(b.date));
      groups.add(DraftGroup(title: "Tomorrow's drafts", notes: tomorrowNotes));
    }

    if (otherNotes.isNotEmpty) {
      otherNotes.sort((a, b) => a.date.compareTo(b.date));
      final first = otherNotes.first.date;
      final last = otherNotes.last.date;

      final String groupTitle;
      if (first.day == last.day && first.month == last.month) {
        groupTitle = DateFormat('MMM d').format(first);
      } else if (first.month == last.month) {
        groupTitle =
            "${DateFormat('MMM d').format(first)} - ${DateFormat('d').format(last)}";
      } else {
        groupTitle =
            "${DateFormat('MMM d').format(first)} - ${DateFormat('MMM d').format(last)}";
      }

      groups.add(
        DraftGroup(title: "$groupTitle upcoming drafts", notes: otherNotes),
      );
    }

    return groups;
  }
}
