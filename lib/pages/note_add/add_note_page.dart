import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebook/core/extensions/extensions.dart';
import 'package:notebook/core/widgets/date_picker.dart';
import 'package:notebook/core/widgets/tag_picker.dart';
import 'package:notebook/model/detail_page_args.dart';
import 'package:notebook/utils/constants/app_colors.dart';
import 'package:notebook/core/widgets/loading.dart';
import 'package:notebook/viewmodel/add_note/add_note_page_view_model.dart';
import 'package:suffadaemon/utils/utils.dart';

class AddNotePage extends ConsumerWidget {
  const AddNotePage({super.key, this.args});

  final DetailArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(addNoteViewModelProvider);

    if (args != null) {
      if (args!.mode == DetailMode.draft) {
        vm.titleController.text = args!.draft!.title;
        vm.descController.text = args!.draft!.content;
        vm.compDate = args!.draft!.date;
        vm.selectedTags = args!.draft!.tag
            .split('|')
            .where((t) => t.isNotEmpty)
            .toList();
      } else {
        vm.titleController.text = args!.note!.title;
        vm.descController.text = args!.note!.content;
        vm.compDate = args!.note!.date;
        vm.selectedTags = args!.note!.tag
            .split('|')
            .where((t) => t.isNotEmpty)
            .toList();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(args != null ? "Edit" : "New Note"),
        surfaceTintColor: Colors.transparent,
        actions: [
          if (args == null)
            buildTopButton("Draft", AppColors.surface, Icons.drafts, () async {
              // show loading
              LoadingOverlay.show(context);

              String response = await vm.draftNote();

              // hide loading
              LoadingOverlay.hide(context);

              if (response == "success" && context.mounted) {
                ScreenMessage.showSuccessToast(
                  context,
                  "New draft successfully saved.",
                );
                context.pop();
              } else {
                ScreenMessage.showErrorToast(context, response);
              }
            }),
          buildTopButton("Save", AppColors.accent, Icons.save, () async {
            // show loading
            LoadingOverlay.show(context);

            String response = await vm.saveNote(args);

            // hide loading
            LoadingOverlay.hide(context);

            if (response == "success" && context.mounted) {
              String msg = args == null
                  ? "New note successfully added."
                  : "successfully updated.";
              ScreenMessage.showSuccessToast(context, msg);
              context.pop(true);
            } else {
              ScreenMessage.showErrorToast(context, response);
            }
          }),
        ],
      ),
      body: buildUI(vm),
      bottomNavigationBar: buildTagMenu(context, vm),
    );
  }

  Widget buildUI(AddNotePageViewModel vm) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [
            // sizedbox
            20.h,

            // header text
            TextField(
              controller: vm.titleController,
              maxLines: 1,
              maxLength: 45,
              style: TextStyle(
                fontSize: SuffaSizes.largeTextSize,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
                overflow: TextOverflow.ellipsis,
              ),
              decoration: InputDecoration(
                hintText: "Title",
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counter: SizedBox.shrink(),
              ),
            ),

            // sizedbox
            20.h,

            // description
            TextField(
              controller: vm.descController,
              style: TextStyle(
                fontSize: SuffaSizes.xMediumTextSize,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              maxLines: null,
              maxLength: 600,
              decoration: InputDecoration(
                hintText: "Description",
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counter: SizedBox.shrink(),
              ),
            ),

            // sizedbox
            40.h,
          ],
        ),
      ),
    );
  }

  Widget buildTagMenu(BuildContext context, AddNotePageViewModel vm) {
    return IntrinsicHeight(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildBottomOption("Add Tag", Icons.tag_sharp, () {
                  TagPickerSheet.show(
                    context,
                    selectedTags: vm.selectedTags,
                    tagMaxLength: 30,
                    onConfirm: (tags) {
                      vm.selectedTags = tags;
                    },
                  );
                }),
                buildBottomOption("Comp Date", Icons.timer, () {
                  BottomDatePicker.show(
                    context,
                    initialDate: vm.compDate ?? DateTime.now(),
                    onConfirm: (date) {
                      vm.compDate = date;
                    },
                  );
                }),
              ],
            ),

            (MediaQuery.of(context).size.height * 0.03).h,
          ],
        ),
      ),
    );
  }

  Widget buildBottomOption(String text, IconData icon, Function() onClick) {
    return GestureDetector(
      onTap: () => onClick(),
      child: Container(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 10.0,
          bottom: 10.0,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.secondaryText,
              size: SuffaSizes.bigMediumTextSize,
            ),
            5.w,
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopButton(
    String text,
    Color bgColor,
    IconData icon,
    Function() onClick,
  ) {
    return GestureDetector(
      onTap: () => onClick(),
      child: Container(
        padding: EdgeInsets.only(top: 10.0, bottom: 5.0, right: 5.0),
        child: Container(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 10.0,
            bottom: 10.0,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.text,
                size: SuffaSizes.bigMediumTextSize,
              ),
              5.w,
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
