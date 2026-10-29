import 'dart:async';

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
  void setArchived(Memo m, bool v) =>
      _repository.setArchived(m.workspaceId, m.id, v);

  Future<void> save(Memo memo, {required bool isNew}) =>
      _repository.save(memo, isNew: isNew);

  Future<void> delete(String workspaceId, String memoId) =>
      _repository.delete(workspaceId, memoId);

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
