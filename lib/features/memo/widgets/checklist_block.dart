import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/features/memo/models/checklist_item.dart';

class ChecklistBlock extends StatefulWidget {
  final List<ChecklistItem> items;
  final ValueChanged<List<ChecklistItem>> onChanged;

  const ChecklistBlock({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  State<ChecklistBlock> createState() => _ChecklistBlockState();
}

class _ChecklistBlockState extends State<ChecklistBlock> {
  final _newItemController = TextEditingController();
  var _nextId = 0;

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  void _toggleItem(ChecklistItem item) {
    widget.onChanged([
      for (final currentItem in widget.items)
        if (currentItem.id == item.id)
          currentItem.copyWith(isDone: !currentItem.isDone)
        else
          currentItem,
    ]);
  }

  void _addItem() {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;

    final id = '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';
    widget.onChanged([
      ...widget.items,
      ChecklistItem(id: id, text: text, isDone: false),
    ]);
    _newItemController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in widget.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Checkbox(
                  value: item.isDone,
                  shape: const CircleBorder(),
                  activeColor: AppTheme.primary,
                  onChanged: (_) => _toggleItem(item),
                ),
                Expanded(
                  child: Text(
                    item.text,
                    style: TextStyle(
                      color: item.isDone
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 4),
          child: Row(
            children: [
              const Icon(Icons.add, color: AppTheme.textSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _newItemController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addItem(),
                  decoration: const InputDecoration(
                    hintText: 'Tambah item',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Tambah item',
                onPressed: _addItem,
                icon: const Icon(Icons.arrow_forward),
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.items.progressText,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
