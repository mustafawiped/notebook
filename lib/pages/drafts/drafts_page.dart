import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:notebook/core/database/app_database.dart';
import 'package:notebook/core/extensions/extensions.dart';
import 'package:notebook/model/detail_page_args.dart';
import 'package:notebook/model/draft_group.dart';
import 'package:notebook/utils/constants/app_colors.dart';
import 'package:notebook/viewmodel/drafts/drafts_page_view_model.dart';
import 'package:suffadaemon/utils/resources/sizes.dart';

class DraftsPage extends ConsumerWidget {
  const DraftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(draftsPageViewProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (vm.refreshStatus) {
              context.pop(true);
            } else {
              context.pop();
            }
          },
        ),
        title: Text("Drafts"),
        surfaceTintColor: Colors.transparent,
      ),
      body: vm.isLoading ? buildLoading() : buildUI(context, vm),
    );
  }

  Widget buildLoading() {
    return Center(child: CircularProgressIndicator(color: AppColors.accent));
  }

  Widget buildUI(BuildContext context, DraftsPageViewModel vm) {
    if (vm.draftGroups.isEmpty) {
      return Center(child: Text("You haven't created any drafts yet :)"));
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemCount: vm.draftGroups.length,
        itemBuilder: (context, index) {
          DraftGroup draftGroup = vm.draftGroups[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // today info 2
              Text(
                draftGroup.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  fontSize: SuffaSizes.xxLargeTextSize,
                ),
              ),

              // sizedbox
              10.h,

              ...draftGroup.notes.map(
                (draft) => buildDraftItem(draft, () async {
                  final data = await context.push(
                    "/noteDetail",
                    extra: DetailArgs(mode: DetailMode.draft, draft: draft),
                  );

                  if (data == true) {
                    vm.loadDrafts();
                    vm.refreshStatus = true;
                  }
                }),
              ),

              //
              10.h,

              if ((vm.draftGroups.length - 1) != index)
                Divider(color: AppColors.surface),

              // sizedbox
              if ((vm.draftGroups.length - 1) != index) 10.h,
            ],
          );
        },
      ),
    );
  }

  Widget buildDraftItem(Draft note, Function() onClick) {
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
}
