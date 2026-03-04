class Draft {
  final int id;
  final String title;
  final String content;
  final String tag;
  final DateTime date;
  final DateTime lastModified;

  Draft({
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.date,
    required this.lastModified,
  });
}
