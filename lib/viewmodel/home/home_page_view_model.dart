import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notebook/model/database/note.dart';

final homeViewModelProvider = ChangeNotifierProvider<HomePageViewModel>((ref) {
  ref.keepAlive();
  return HomePageViewModel(ref);
});

class HomePageViewModel extends ChangeNotifier {
  final Ref ref;
  String todayDate = "";

  HomePageViewModel(this.ref) {
    todayDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    _isLoading = false;
    notifyListeners();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  final List<Note> _notes = [];
  List<Note> get notes => _notes;
}
