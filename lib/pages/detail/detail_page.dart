import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:notebook/core/extensions/extensions.dart';
import 'package:notebook/core/widgets/loading.dart';
import 'package:notebook/model/detail_page_args.dart';
import 'package:notebook/utils/constants/app_colors.dart';
import 'package:notebook/viewmodel/detail/detail_page_view_model.dart';
import 'package:suffadaemon/utils/helpers/toasts.dart';
import 'package:suffadaemon/utils/popup/popup.dart';
import 'package:suffadaemon/utils/resources/sizes.dart';

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key, required this.args});

  final DetailArgs args;

  void deleteData(
    BuildContext context,
    DetailPageViewModel vm,
    DetailMode mode,
  ) {
    SuffaPopup.showPopup(
      dialogBgColor: AppColors.background,
      cancelBtnColor: AppColors.surface,
      okBtnColor: AppColors.accent,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.bold,
        fontSize: SuffaSizes.bigMediumTextSize,
      ),
      descTextStyle: TextStyle(color: AppColors.secondaryText),
      context,
      "Are you sure you want to delete it?",
      "Are you sure you want to delete the note? If you delete it, you can restore it from the history section at any time.",
      "Delete",
      PopupType.warning,
      () async {
        // show loading
        LoadingOverlay.show(context);

        // db query
        String response = await vm.deleteData(args);

        // hide loading
        LoadingOverlay.hide(context);

        // control
        if (response == "success" && context.mounted) {
          ScreenMessage.showSuccessToast(
            context,
            "Note was successfully deleted.",
          );
          context.pop(true);
        } else {
          ScreenMessage.showErrorToast(context, response);
        }
      },
      declineBtnText: "Forget it",
      declineBtnFnc: () {},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(detailPageProvider);

    String title, desc, date, tags;

    if (args.mode == DetailMode.note) {
      title = args.note!.title;
      desc = args.note!.content;
      date = DateFormat('d MMMM yyyy - h:mm a').format(args.note!.date);
      tags = args.note!.tag.replaceAll("|", " - ");
    } else {
      title = args.draft!.title;
      desc = args.draft!.content;
      date = DateFormat('d MMMM yyyy - h:mm a').format(args.draft!.date);
      tags = args.draft!.tag.replaceAll("|", " - ");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(args.mode == DetailMode.note ? "Note Detail" : "Draft"),
        surfaceTintColor: Colors.transparent,
        actions: [
          buildTopButton(
            "Delete",
            Colors.transparent,
            Icons.delete,
            () => deleteData(context, vm, args.mode),
          ),

          if (args.mode == DetailMode.draft)
            buildTopButton(
              "Add Notes",
              Colors.transparent,
              Icons.add,
              () async {
                // show loading
                LoadingOverlay.show(context);

                // db query
                String response = await vm.addNotes(args);

                // hide loading
                LoadingOverlay.hide(context);

                // control
                if (response == "success" && context.mounted) {
                  ScreenMessage.showSuccessToast(
                    context,
                    "notes from the drafts have been successfully added :)",
                  );
                  context.pop(true);
                } else {
                  ScreenMessage.showErrorToast(context, response);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              buildItem(
                "Title",
                title,
                SuffaSizes.bigMediumTextSize,
                SuffaSizes.xxLargeTextSize,
              ),

              // desc
              buildItem(
                "Description",
                desc,
                SuffaSizes.bigMediumTextSize,
                SuffaSizes.mediumTextSize,
              ),

              // title
              buildItem(
                "Expected Completion Date",
                date,
                SuffaSizes.bigMediumTextSize,
                SuffaSizes.mediumTextSize,
              ),

              // title
              if (tags.isNotEmpty)
                buildItem(
                  "Tags",
                  tags,
                  SuffaSizes.bigMediumTextSize,
                  SuffaSizes.mediumTextSize,
                ),
              // title
              if (args.mode == DetailMode.draft)
                buildItem(
                  "Last transaction date",
                  DateFormat(
                    'd MMMM yyyy - h:mm a',
                  ).format(args.draft!.lastModified),
                  SuffaSizes.bigMediumTextSize,
                  SuffaSizes.mediumTextSize,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(String header, String desc, double hTxtSz, double dTxtSz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              header,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: hTxtSz,
              ),
              maxLines: 1,
            ),
            Tooltip(
              message: "Copy data",
              child: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: desc));
                },
                icon: Icon(
                  Icons.copy_all,
                  color: AppColors.accent,
                  size: SuffaSizes.bigMediumTextSize,
                ),
              ),
            ),
          ],
        ),
        // desc
        Text(
          desc,
          style: TextStyle(
            color: AppColors.text,
            fontSize: dTxtSz,
            fontWeight: FontWeight.bold,
          ),
          maxLines: null,
        ),
      ],
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
                color: AppColors.accent,
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
