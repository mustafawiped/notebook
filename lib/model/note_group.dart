import 'package:notebook/core/database/app_database.dart';

class NoteGroup {
  final String title; // "Today", "Tomorrow", "Mar 3 - Mar 6"
  final List<Note> notes;

  NoteGroup({required this.title, required this.notes});
}
