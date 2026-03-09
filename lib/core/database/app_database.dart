import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// Tablolar
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get tag => text()();
  DateTimeColumn get date => dateTime()();
}

class Drafts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get tag => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get lastModified => dateTime()();
}

@DriftDatabase(tables: [Notes, Drafts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'notebook_db'));

  @override
  int get schemaVersion => 2;

  // -------- NOTES --------
  Future<List<Note>> getNotes() => select(notes).get();
  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);
  Future<bool> updateNote(NotesCompanion note) => update(notes).replace(note);
  Future<int> deleteNote(int id) =>
      (delete(notes)..where((t) => t.id.equals(id))).go();

  // -------- DRAFTS --------
  Future<List<Draft>> getDrafts() => select(drafts).get();
  Future<int> insertDraft(DraftsCompanion draft) => into(drafts).insert(draft);
  Future<bool> updateDraft(DraftsCompanion draft) =>
      update(drafts).replace(draft);
  Future<int> deleteDraft(int id) =>
      (delete(drafts)..where((t) => t.id.equals(id))).go();
}
