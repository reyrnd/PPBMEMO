import 'dart:async';

import 'package:memospace/features/memo/data/dummy_memos.dart';
import 'package:memospace/features/memo/models/memo.dart';

class MemoRepository {
  MemoRepository({List<Memo>? initialMemos})
      : _memos = List<Memo>.of(initialMemos ?? dummyMemos);

  final List<Memo> _memos;
  final StreamController<List<Memo>> _memoChanges =
      StreamController<List<Memo>>.broadcast();

  List<Memo> getMemos() => List<Memo>.unmodifiable(_memos);

  Stream<List<Memo>> watchMemos() {
    return Stream<List<Memo>>.multi((controller) {
      controller.add(getMemos());
      final subscription = _memoChanges.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      controller.onCancel = subscription.cancel;
    });
  }

  Memo? getMemo(String id) {
    for (final memo in _memos) {
      if (memo.id == id) return memo;
    }
    return null;
  }

  void saveMemo(Memo memo) {
    final index =
        _memos.indexWhere((existingMemo) => existingMemo.id == memo.id);
    if (index == -1) {
      _memos.add(memo);
    } else {
      _memos[index] = memo;
    }
    _notifyChanges();
  }

  bool deleteMemo(String id) {
    final originalLength = _memos.length;
    _memos.removeWhere((memo) => memo.id == id);
    final removedCount = originalLength - _memos.length;
    if (removedCount > 0) {
      _notifyChanges();
      return true;
    }
    return false;
  }

  bool toggleBookmark(String id) {
    final index = _memos.indexWhere((memo) => memo.id == id);
    if (index == -1) return false;

    final memo = _memos[index];
    _memos[index] = memo.copyWith(isBookmarked: !memo.isBookmarked);
    _notifyChanges();
    return true;
  }

  void _notifyChanges() {
    _memoChanges.add(getMemos());
  }

  Future<void> dispose() => _memoChanges.close();
}
