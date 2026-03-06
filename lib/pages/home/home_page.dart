import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:notebook/core/database/app_database.dart';
import 'package:notebook/model/note_group.dart';
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
      body: SafeArea(
        child: vm.isLoading ? buildLoading() : buildUI(context, vm),
      ),
      floatingActionButton: vm.isLoading
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final isAdded = await context.push<bool>("/addNote");

                if (isAdded == true) {
                  ref.read(homeViewModelProvider).loadNotes();
                }
              },
              backgroundColor: AppColors.accent,
              child: Icon(Icons.add, color: AppColors.text),
            ),
    );
  }

  Widget buildLoading() {
    return Center(child: CircularProgressIndicator(color: AppColors.accent));
  }

  Widget buildUI(BuildContext context, HomePageViewModel vm) {
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

          // notes
          Expanded(
            child: ListView.builder(
              itemCount: vm.noteGroups.length,
              itemBuilder: (context, index) {
                NoteGroup noteGroup = vm.noteGroups[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // today info 2
                    Text(
                      noteGroup.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                        fontSize: SuffaSizes.xxLargeTextSize,
                      ),
                    ),

                    // sizedbox
                    10.h,

                    ...noteGroup.notes.map(
                      (note) => buildNoteItem(note, () async {
                        final data = await context.push(
                          "/noteDetail",
                          extra: note,
                        );

                        if (data == true) {
                          vm.loadNotes();
                        }
                      }),
                    ),

                    //
                    10.h,

                    if ((vm.noteGroups.length - 1) != index)
                      Divider(color: AppColors.surface),

                    // sizedbox
                    if ((vm.noteGroups.length - 1) != index) 10.h,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNoteItem(Note note, Function() onClick) {
    return GestureDetector(
      onTap: () => onClick(),
      child: Container(
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
          border: getNoteBorder(note.date),
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

            // time & tags
            Wrap(
              children: [
                // time
                Text(
                  DateFormat('h:mm a').format(note.date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                    fontSize: SuffaSizes.mediumTextSize,
                  ),
                ),

                // sizedbox
                3.w,

                // tags
                ...note.tag
                    .split('|')
                    .where((t) => t.isNotEmpty)
                    .map(
                      (tag) => Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: SuffaSizes.smallTextSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
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

  Border getNoteBorder(DateTime noteDate) {
    final now = DateTime.now();
    final diff = noteDate.difference(now);

    if (diff.isNegative) return Border.all(color: AppColors.accent, width: 1.5);
    if (diff.inHours <= 3) {
      return Border.all(color: AppColors.warning, width: 1.5);
    }
    return Border.all(color: Colors.transparent);
  }
}
