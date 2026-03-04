import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebook/core/extensions/extensions.dart';
import 'package:notebook/utils/components/date_picker.dart';
import 'package:notebook/utils/constants/app_colors.dart';
import 'package:notebook/utils/helpers/loading.dart';
import 'package:notebook/viewmodel/add_note/add_note_page_view_model.dart';
import 'package:suffadaemon/utils/utils.dart';

class AddNotePage extends ConsumerWidget {
  const AddNotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(addNoteViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("New Note"),
        surfaceTintColor: Colors.transparent,
        actions: [
          buildTopButton("Draft", AppColors.surface, Icons.drafts, () {}),
          buildTopButton("Save", AppColors.accent, Icons.save, () async {
            // show loading
            LoadingOverlay.show(context);

            String response = await vm.saveNote();

            if (response == "success") {
              ScreenMessage.showSuccessToast(
                context,
                "Başarıyla yeni not eklendi.",
              );
              context.pop();
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
                buildBottomOption("Add Tag", Icons.tag_sharp, () {}),
                buildBottomOption("Comp Date", Icons.timer, () {
                  print("MURTAZA");
                  BottomDatePicker.show(
                    context,
                    initialDate: DateTime.now(),
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
      onTap: () => onClick,
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
