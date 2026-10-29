import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memospace/features/workspace/data/workspace_repository.dart';
import 'package:memospace/features/workspace/models/workspace.dart';

class WorkspaceCubit extends Cubit<List<Workspace>> {
  final WorkspaceRepository _repo;
  late final StreamSubscription _sub;

  WorkspaceCubit(this._repo) : super(const []) {
    _sub = _repo.watchWorkspaces().listen(emit);
  }

  void togglePin(String id) {
    final w = state.firstWhere((w) => w.id == id);
    _repo.togglePin(id, !w.hasPin);
  }

  Future<void> create(String title, String desc, String category, bool pin) =>
      _repo.create(
          title: title, description: desc, category: category, pin: pin);

  Future<void> join(String code) => _repo.joinByCode(code);

  Future<void> inviteByEmail(String workspaceId, String email) =>
      _repo.inviteByEmail(workspaceId, email);

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
