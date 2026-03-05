import 'package:flutter/material.dart';
import 'package:notebook/utils/constants/app_colors.dart';

class TagPickerSheet extends StatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>) onConfirm;

  const TagPickerSheet({
    super.key,
    required this.selectedTags,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> selectedTags,
    required Function(List<String>) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          TagPickerSheet(selectedTags: selectedTags, onConfirm: onConfirm),
    );
  }

  @override
  State<TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<TagPickerSheet> {
  late List<String> _selected;
  final TextEditingController _newTagController = TextEditingController();

  final List<String> _tags = [
    'Personal',
    'Work',
    'Ideas',
    'Important',
    'Todo',
    'Journal',
    'Study',
    'Health',
  ];

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedTags);

    for (final tag in widget.selectedTags) {
      if (!_tags.contains(tag)) {
        _tags.add(tag);
      }
    }
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      _selected.contains(tag) ? _selected.remove(tag) : _selected.add(tag);
    });
  }

  void _addNewTag() {
    final tag = _newTagController.text.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _selected.add(tag);
      _newTagController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.secondaryText.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // header text
          const Text(
            "Select Tags",
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // desc
          const Text(
            "Tags that have just been created are not permanent.",
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),

          const SizedBox(height: 20),

          // tag list
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              final isSelected = _selected.contains(tag);
              return GestureDetector(
                onTap: () => _toggleTag(tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        tag,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.secondaryText,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // create new tag
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newTagController,
                  style: const TextStyle(color: AppColors.text, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Create new tag...",
                    hintStyle: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _addNewTag(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _addNewTag,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Confirm butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onConfirm(_selected);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
