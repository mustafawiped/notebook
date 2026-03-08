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

class AddNotePage extends ConsumerStatefulWidget {
  final DetailArgs? args;
  const AddNotePage({super.key, this.args});

  @override
  ConsumerState<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends ConsumerState<AddNotePage> {
  FocusNode textFocusNode = FocusNode();
  FocusNode descFocusNode = FocusNode();

  @override
  void dispose() {
    textFocusNode.dispose();
    descFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(addNoteViewModelProvider);

    if (widget.args != null) {
      if (widget.args!.mode == DetailMode.draft) {
        vm.titleController.text = widget.args!.draft!.title;
        vm.descController.text = widget.args!.draft!.content;
        vm.compDate = widget.args!.draft!.date;
        vm.selectedTags = widget.args!.draft!.tag
            .split('|')
            .where((t) => t.isNotEmpty)
            .toList();
      } else {
        vm.titleController.text = widget.args!.note!.title;
        vm.descController.text = widget.args!.note!.content;
        vm.compDate = widget.args!.note!.date;
        vm.selectedTags = widget.args!.note!.tag
            .split('|')
            .where((t) => t.isNotEmpty)
            .toList();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args != null ? "Edit" : "New Note"),
        surfaceTintColor: Colors.transparent,
        actions: [
          if (widget.args == null)
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

            String response = await vm.saveNote(widget.args);

            // hide loading
            LoadingOverlay.hide(context);

            if (response == "success" && context.mounted) {
              String msg = widget.args == null
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
              focusNode: textFocusNode,
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
              focusNode: descFocusNode,
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
                  textFocusNode.unfocus();
                  descFocusNode.unfocus();
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
                  textFocusNode.unfocus();
                  descFocusNode.unfocus();
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
