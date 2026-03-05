import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notebook/core/database/app_database.dart';
import 'package:notebook/model/note_group.dart';

final homeViewModelProvider = ChangeNotifierProvider<HomePageViewModel>((ref) {
  ref.keepAlive();
  return HomePageViewModel(ref);
});

class HomePageViewModel extends ChangeNotifier {
  final Ref ref;

  String todayDate = "";

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<NoteGroup> _noteGroups = [];
  List<NoteGroup> get noteGroups => _noteGroups;

  HomePageViewModel(this.ref) {
    todayDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    loadNotes();
    notifyListeners();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    final notes = await ref.read(databaseProvider).getNotes();
    _noteGroups = _groupNotes(notes);

    _isLoading = false;
    notifyListeners();
  }

  List<NoteGroup> _groupNotes(List<Note> notes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final todayNotes = <Note>[];
    final tomorrowNotes = <Note>[];
    final otherNotes = <Note>[];

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

    final groups = <NoteGroup>[];

    if (todayNotes.isNotEmpty) {
      todayNotes.sort((a, b) => a.date.compareTo(b.date));
      groups.add(NoteGroup(title: "Today's notes", notes: todayNotes));
    }

    if (tomorrowNotes.isNotEmpty) {
      tomorrowNotes.sort((a, b) => a.date.compareTo(b.date));
      groups.add(NoteGroup(title: "Tomorrow's notes", notes: tomorrowNotes));
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

      groups.add(NoteGroup(title: "$groupTitle upcoming", notes: otherNotes));
    }

    return groups;
  }
}
