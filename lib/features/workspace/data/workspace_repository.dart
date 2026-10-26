import 'dart:async';

import 'package:memospace/features/workspace/data/dummy_workspaces.dart';
import 'package:memospace/features/workspace/models/workspace.dart';
import 'package:memospace/features/workspace/models/workspace_member.dart';

class WorkspaceRepository {
  WorkspaceRepository({
    List<Workspace>? initialWorkspaces,
    Map<String, String>? inviteCodes,
    Map<String, List<WorkspaceMember>>? membersByWorkspace,
  })  : _workspaces = List<Workspace>.of(
          initialWorkspaces ?? dummyWorkspaces,
        ),
        _inviteCodes = inviteCodes == null
            ? {
                for (final workspace in initialWorkspaces ?? dummyWorkspaces)
                  workspace.id.padLeft(6, '0'): workspace.id,
              }
            : {
                for (final entry in inviteCodes.entries)
                  entry.key.trim().toUpperCase(): entry.value,
              },
        _membersByWorkspace = {
          for (final workspace in initialWorkspaces ?? dummyWorkspaces)
            workspace.id: List<WorkspaceMember>.of(
              membersByWorkspace?[workspace.id] ??
                  _defaultMembersFor(workspace),
            ),
        };

  final List<Workspace> _workspaces;
  final Map<String, String> _inviteCodes;
  final Map<String, List<WorkspaceMember>> _membersByWorkspace;
  final StreamController<List<Workspace>> _workspaceChanges =
      StreamController<List<Workspace>>.broadcast();
  var _nextWorkspaceNumber = 1;
  var _nextInviteCode = 1;

  Stream<List<Workspace>> watchWorkspaces() {
    return Stream<List<Workspace>>.multi((controller) {
      controller.add(_workspaceSnapshot());
      final subscription = _workspaceChanges.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      controller.onCancel = subscription.cancel;
    });
  }

  Workspace? getById(String id) {
    for (final workspace in _workspaces) {
      if (workspace.id == id) return workspace;
    }
    return null;
  }

  List<Workspace> getWorkspaces() => _workspaceSnapshot();

  Workspace create({
    required String title,
    required String category,
    required WorkspaceMember owner,
    bool pinOnHome = false,
  }) {
    final id = 'workspace-${DateTime.now().microsecondsSinceEpoch}-'
        '${_nextWorkspaceNumber++}';
    final workspace = Workspace(
      id: id,
      category: category,
      title: title,
      memoCount: 0,
      fileCount: 0,
      hasPin: pinOnHome,
      time: 'Baru saja',
      memberInitials: [owner.initials],
    );

    _workspaces.insert(0, workspace);
    _membersByWorkspace[id] = [owner];
    _inviteCodes[_generateInviteCode()] = id;
    _notifyChanges();
    return workspace;
  }

  Workspace joinByCode(
    String code, {
    required WorkspaceMember member,
  }) {
    final workspaceId = _inviteCodes[code.trim().toUpperCase()];
    if (workspaceId == null) {
      throw StateError('Kode undangan tidak valid.');
    }

    final workspace = getById(workspaceId);
    if (workspace == null) {
      throw StateError('Workspace dari kode undangan tidak ditemukan.');
    }

    final members = _membersByWorkspace.putIfAbsent(workspaceId, () => []);
    if (!members
        .any((existingMember) => existingMember.userId == member.userId)) {
      members.add(member);
      _replaceWorkspace(
        workspace.copyWith(
          memberInitials: [...workspace.memberInitials, member.initials],
        ),
      );
      _notifyChanges();
    }

    return _requireWorkspace(workspaceId);
  }

  String getInviteCode(String workspaceId) {
    for (final entry in _inviteCodes.entries) {
      if (entry.value == workspaceId) return entry.key;
    }
    throw StateError('Kode undangan workspace tidak ditemukan.');
  }

  Workspace togglePin(String id) {
    final workspace = _requireWorkspace(id);
    final updatedWorkspace = workspace.copyWith(hasPin: !workspace.hasPin);
    _replaceWorkspace(updatedWorkspace);
    _notifyChanges();
    return updatedWorkspace;
  }

  Workspace rename(String id, String title) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Nama workspace wajib diisi.');
    }
    final updatedWorkspace =
        _requireWorkspace(id).copyWith(title: normalizedTitle);
    _replaceWorkspace(updatedWorkspace);
    _notifyChanges();
    return updatedWorkspace;
  }

  bool leave(String id) {
    final index = _workspaces.indexWhere((workspace) => workspace.id == id);
    if (index == -1) return false;

    _workspaces.removeAt(index);
    _membersByWorkspace.remove(id);
    _inviteCodes.removeWhere((_, workspaceId) => workspaceId == id);
    _notifyChanges();
    return true;
  }

  List<WorkspaceMember> getMembers(String workspaceId) {
    if (getById(workspaceId) == null) {
      throw StateError('Workspace tidak ditemukan: $workspaceId');
    }
    return List<WorkspaceMember>.unmodifiable(
      _membersByWorkspace[workspaceId] ?? const [],
    );
  }

  Future<void> dispose() => _workspaceChanges.close();

  static List<WorkspaceMember> _defaultMembersFor(Workspace workspace) {
    return [
      for (var index = 0; index < workspace.memberInitials.length; index++)
        WorkspaceMember(
          userId: '${workspace.id}-member-$index',
          name: workspace.memberInitials[index],
          initials: workspace.memberInitials[index],
          role: index == 0 ? MemberRole.owner : MemberRole.member,
        ),
    ];
  }

  Workspace _requireWorkspace(String id) {
    final workspace = getById(id);
    if (workspace == null) {
      throw StateError('Workspace tidak ditemukan: $id');
    }
    return workspace;
  }

  void _replaceWorkspace(Workspace updatedWorkspace) {
    final index = _workspaces
        .indexWhere((workspace) => workspace.id == updatedWorkspace.id);
    if (index == -1) {
      throw StateError('Workspace tidak ditemukan: ${updatedWorkspace.id}');
    }
    _workspaces[index] = updatedWorkspace;
  }

  List<Workspace> _workspaceSnapshot() =>
      List<Workspace>.unmodifiable(_workspaces);

  String _generateInviteCode() {
    while (_nextInviteCode <= 999999) {
      final code = (_nextInviteCode++).toString().padLeft(6, '0');
      if (!_inviteCodes.containsKey(code)) return code;
    }
    throw StateError('Kode undangan dummy sudah habis.');
  }

  void _notifyChanges() {
    _workspaceChanges.add(_workspaceSnapshot());
  }
}
