class History {
  final int id;
  final int noteId;
  final String title;
  final String content;
  final String tag;
  final DateTime date;
  final DateTime deletedAt;

  History({
    required this.id,
    required this.noteId,
    required this.title,
    required this.content,
    required this.tag,
    required this.date,
    required this.deletedAt,
  });
}
