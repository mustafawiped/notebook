import 'package:notebook/core/database/app_database.dart';

class DraftGroup {
  final String title;
  final List<Draft> notes;

  DraftGroup({required this.title, required this.notes});
}
