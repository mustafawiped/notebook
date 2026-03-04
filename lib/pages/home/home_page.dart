import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:notebook/model/database/note.dart';
import 'package:notebook/utils/constants/app_colors.dart';
import 'package:notebook/core/extensions/extensions.dart';
import 'package:notebook/viewmodel/home/home_page_view_model.dart';
import 'package:suffadaemon/utils/utils.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(homeViewModelProvider);

    return Scaffold(
      body: SafeArea(child: vm.isLoading ? buildLoading() : buildUI(vm)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push("/addNote"),
        backgroundColor: AppColors.accent,
        child: Icon(Icons.add, color: AppColors.text),
      ),
    );
  }

  Widget buildLoading() {
    return Center(child: CircularProgressIndicator(color: AppColors.accent));
  }

  Widget buildUI(HomePageViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // sizedbox
          20.h,

          // header text
          buildHeaderText(),

          // sizedbox
          20.h,

          // today info
          Text(
            vm.todayDate,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),

          // sizedbox
          5.h,

          // today info 2
          Text(
            "Today's Notes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.text,
              fontSize: SuffaSizes.xxLargeTextSize,
            ),
          ),

          // sizedbox
          10.h,

          // notes
          Expanded(
            child: ListView.builder(
              itemCount: vm.notes.length,
              itemBuilder: (context, index) {
                return buildNoteItem(vm.notes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Container buildNoteItem(Note note) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 10.0,
        bottom: 10.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Text(
            note.title,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.text,
              fontSize: SuffaSizes.xxLargeTextSize,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // description
          Text(
            note.content,
            textAlign: TextAlign.start,
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
              fontSize: SuffaSizes.xMediumTextSize,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // sizedbox
          5.h,

          // hour
          Text(
            DateFormat('h:mm a').format(DateTime.now()),
            textAlign: TextAlign.start,
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              fontSize: SuffaSizes.mediumTextSize,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeaderText() {
    return Row(
      children: [
        Text(
          "Note",
          style: TextStyle(
            color: AppColors.accent,
            fontSize: SuffaSizes.bigLargeTextSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "book",
          style: TextStyle(
            color: AppColors.text,
            fontSize: SuffaSizes.bigLargeTextSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
