import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memospace/features/memo/data/memo_repository.dart';
import 'package:memospace/features/memo/models/memo.dart';

class MemoCubit extends Cubit<List<Memo>> {
  final MemoRepository _repository;
  late final StreamSubscription<List<Memo>> _subscription;

  MemoCubit(this._repository) : super(const []) {
    _subscription = _repository.watchAllMyMemos().listen(emit);
  }

  void toggleBookmark(Memo m) =>
      _repository.toggleBookmark(m.workspaceId, m.id, !m.isBookmarked);
  Future<void> setArchived(Memo m, bool v) =>
      _repository.setArchived(m.workspaceId, m.id, v);

  Future<void> save(Memo memo, {required bool isNew}) =>
      _repository.save(memo, isNew: isNew);

  Future<void> delete(String workspaceId, String memoId) =>
      _repository.delete(workspaceId, memoId);

  void moveOnCanvas(Memo m, Offset o) =>
      _repository.moveOnCanvas(m.workspaceId, m.id, o.dx, o.dy);

  void setBoardStatus(Memo m, String status) =>
      _repository.setBoardStatus(m.workspaceId, m.id, status);

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
