// Model
import 'package:notebook/core/database/app_database.dart';

enum DetailMode { note, draft }

class DetailArgs {
  final Note? note;
  final Draft? draft;
  final DetailMode mode;

  DetailArgs({this.note, required this.mode, this.draft});
}
