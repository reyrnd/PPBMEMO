import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/memo.dart';

abstract class MemoState {}

class MemoLoading extends MemoState {}

class MemoLoaded extends MemoState {
  final List<Memo> memos;
  MemoLoaded(this.memos);
}

class MemoError extends MemoState {
  final String message;
  MemoError(this.message);
}

class MemoCubit extends Cubit<MemoState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _memosSubscription;
  final List<Memo> _localMemos = [];
  List<String> _activeWorkspaceIds = [];

  MemoCubit() : super(MemoLoaded(const []));

  void streamMemos(List<String> workspaceIds) {
    _activeWorkspaceIds = List<String>.from(workspaceIds);
    _memosSubscription?.cancel();

    if (workspaceIds.isEmpty) {
      emit(MemoLoaded(List.unmodifiable(_localMemos)));
      return;
    }

    try {
      final memoStreams = workspaceIds.map((workspaceId) {
        return _firestore
            .collection('workspaces')
            .doc(workspaceId)
            .collection('memos')
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => Memo.fromMap(
                      doc.data(),
                      doc.id,
                      workspaceId: workspaceId,
                    ))
                .toList());
      });
      _memosSubscription =
          Rx.combineLatestList<List<Memo>>(memoStreams).listen((memoLists) {
        final firestoreMemos = memoLists.expand((memos) => memos).toList();
        final firestoreIds = firestoreMemos.map((m) => m.id).toSet();
        final remainingLocal =
            _localMemos.where((m) => !firestoreIds.contains(m.id)).toList();
        final merged = [...firestoreMemos, ...remainingLocal]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        emit(MemoLoaded(merged));
      }, onError: (error) {
        emit(MemoLoaded(List.unmodifiable(_localMemos)));
      });
    } catch (e) {
      emit(MemoLoaded(List.unmodifiable(_localMemos)));
    }
  }

  Future<void> refresh() async {
    streamMemos(_activeWorkspaceIds);
    await Future.delayed(const Duration(milliseconds: 450));
  }

  Future<void> syncAuthorNameForCurrentUser(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'demo-naya';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    final newInitials = parts.isNotEmpty
        ? (parts.first[0] + (parts.length > 1 ? parts.last[0] : ''))
            .toUpperCase()
        : 'NA';

    // Update local memos
    for (int i = 0; i < _localMemos.length; i++) {
      final m = _localMemos[i];
      if (m.authorId == uid || m.authorId == 'demo-naya' || m.authorId.isEmpty) {
        _localMemos[i] = m.copyWith(
          authorName: trimmed,
          assignee: newInitials,
        );
      }
    }

    // Update current state immediately
    if (state is MemoLoaded) {
      final updated = (state as MemoLoaded).memos.map((m) {
        if (m.authorId == uid || m.authorId == 'demo-naya' || m.authorId.isEmpty) {
          return m.copyWith(
            authorName: trimmed,
            assignee: newInitials,
          );
        }
        return m;
      }).toList();
      emit(MemoLoaded(updated));
    }

    // Persist to Firestore across all active workspaces (memos, comments, activities)
    if (user == null) return;
    for (final wsId in _activeWorkspaceIds) {
      if (wsId.isEmpty) continue;
      try {
        final memosSnap = await _firestore
            .collection('workspaces')
            .doc(wsId)
            .collection('memos')
            .where('authorId', isEqualTo: user.uid)
            .get();
        final batch = _firestore.batch();
        for (final doc in memosSnap.docs) {
          batch.update(doc.reference, {
            'authorName': trimmed,
            'assignee': newInitials,
          });
        }
        await batch.commit();
      } catch (_) {}

      try {
        final actSnap = await _firestore
            .collection('workspaces')
            .doc(wsId)
            .collection('activities')
            .where('actorId', isEqualTo: user.uid)
            .get();
        final actBatch = _firestore.batch();
        for (final doc in actSnap.docs) {
          actBatch.update(doc.reference, {'actorName': trimmed});
        }
        await actBatch.commit();
      } catch (_) {}
    }
  }

  Future<String> addMemo({
    required String workspaceId,
    required String title,
    required String content,
    required String tag,
    required String dueDate,
    String checklistTitle = '',
    String status = 'todo',
    String assignee = '',
    String assigneeTone = 'dark',
    List<Map<String, String>>? assignees,
    double? boardX,
    double? boardY,
    List<Map<String, dynamic>> attachments = const [],
    List<Map<String, dynamic>> checklist = const [],
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final authorId = user?.uid ?? 'demo-naya';
    final authorName =
        (user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!
            : 'Naya Anindita';

    String resolvedAssignee = assignee;
    if (resolvedAssignee.isEmpty) {
      if (assignees != null && assignees.isNotEmpty) {
        resolvedAssignee = assignees
            .map((a) => (a['initials'] ?? '').trim())
            .where((s) => s.isNotEmpty)
            .join(', ');
      }
      if (resolvedAssignee.isEmpty) {
        final parts =
            authorName.trim().split(' ').where((p) => p.isNotEmpty).toList();
        resolvedAssignee = parts.isNotEmpty
            ? (parts.first[0] + (parts.length > 1 ? parts.last[0] : ''))
                .toUpperCase()
            : 'NA';
      }
    }

    final resolvedAssignees = (assignees != null && assignees.isNotEmpty)
        ? assignees
        : [
            {
              'initials': resolvedAssignee.split(',').first.trim(),
              'name': authorName,
              'tone': assigneeTone.isEmpty ? 'dark' : assigneeTone,
            }
          ];
    final resolvedTone = resolvedAssignees.first['tone'] ?? assigneeTone;

    double? progress;
    if (checklist.isNotEmpty) {
      final done = checklist.where((c) => c['done'] == true).length;
      progress = done / checklist.length;
    }

    final cleanContent = content
        .replaceAll(RegExp(r'\*\*\*(.*?)\*\*\*'), r'$1')
        .replaceAll(RegExp(r'_\*\*(.*?)\*\*_'), r'$1')
        .replaceAll(RegExp(r'\*\*_(.*?)_\*\*'), r'$1')
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'_(.*?)_'), r'$1')
        .trim();

    final previewText = cleanContent.isNotEmpty
        ? (cleanContent.length > 80
            ? '${cleanContent.substring(0, 80)}...'
            : cleanContent)
        : (checklist.isNotEmpty
            ? '${checklistTitle.isNotEmpty ? '$checklistTitle: ' : ''}${checklist.map((c) => c['text']).join(' · ')}'
            : (attachments.isNotEmpty
                ? '${attachments.length} attachment(s): ${attachments.map((a) => a['name']).join(', ')}'
                : 'Tap to view memo details'));

    try {
      if (user != null && workspaceId.isNotEmpty) {
        final newMemoData = <String, dynamic>{
          'title': title.trim(),
          'content': content,
          'preview': previewText,
          'meta': 'Edited just now',
          'tag': tag.isEmpty ? 'Personal' : tag,
          'dueDate': dueDate,
          'authorId': authorId,
          'authorName': authorName,
          'workspaceId': workspaceId,
          'progress': progress,
          'checklistTitle': checklistTitle,
          'status': status,
          'assignee': resolvedAssignee,
          'assigneeTone': resolvedTone,
          'assignees': resolvedAssignees,
          'attachments': attachments,
          'checklist': checklist,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (boardX != null) newMemoData['boardX'] = boardX;
        if (boardY != null) newMemoData['boardY'] = boardY;

        final memoDoc = _firestore
            .collection('workspaces')
            .doc(workspaceId)
            .collection('memos')
            .doc();
        await memoDoc.set(newMemoData);
        try {
          await _firestore.collection('workspaces').doc(workspaceId).update({
            'memoCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
        try {
          await _writeActivity(
            workspaceId: workspaceId,
            memoId: memoDoc.id,
            type: 'memo_created',
            targetTitle: title.trim(),
          );
        } catch (_) {}
        return memoDoc.id;
      }
    } catch (_) {}

    // Local fallback when offline or demo user
    final localId = 'memo-${DateTime.now().millisecondsSinceEpoch}';
    final newMemo = Memo(
      id: localId,
      title: title.trim(),
      preview: previewText,
      content: content,
      meta: 'Edited just now',
      tag: tag.isEmpty ? 'Personal' : tag,
      dueDate: dueDate,
      authorId: authorId,
      authorName: authorName,
      workspaceId: workspaceId,
      updatedAt: DateTime.now(),
      progress: progress,
      checklistTitle: checklistTitle,
      status: status,
      assignee: resolvedAssignee,
      assigneeTone: resolvedTone,
      assignees: resolvedAssignees,
      boardX: boardX,
      boardY: boardY,
      attachments: attachments,
      checklist: checklist,
    );
    _localMemos.insert(0, newMemo);
    final current = state is MemoLoaded ? (state as MemoLoaded).memos : <Memo>[];
    emit(MemoLoaded([newMemo, ...current]));
    return localId;
  }

  Future<void> updateMemo(
    String workspaceId,
    String id,
    String title,
    String content, {
    String? tag,
    String? dueDate,
    String? checklistTitle,
    String? status,
    String? assignee,
    String? assigneeTone,
    List<Map<String, String>>? assignees,
    List<Map<String, dynamic>>? attachments,
    List<Map<String, dynamic>>? checklist,
  }) async {
    double? progress;
    if (checklist != null && checklist.isNotEmpty) {
      final done = checklist.where((c) => c['done'] == true).length;
      progress = done / checklist.length;
    }

    final cleanContent = content
        .replaceAll(RegExp(r'\*\*\*(.*?)\*\*\*'), r'$1')
        .replaceAll(RegExp(r'_\*\*(.*?)\*\*_'), r'$1')
        .replaceAll(RegExp(r'\*\*_(.*?)_\*\*'), r'$1')
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'_(.*?)_'), r'$1')
        .trim();

    final previewText = cleanContent.isNotEmpty
        ? (cleanContent.length > 80
            ? '${cleanContent.substring(0, 80)}...'
            : cleanContent)
        : (checklist != null && checklist.isNotEmpty
            ? '${(checklistTitle != null && checklistTitle.isNotEmpty) ? '$checklistTitle: ' : ''}${checklist.map((c) => c['text']).join(' · ')}'
            : (attachments != null && attachments.isNotEmpty
                ? '${attachments.length} attachment(s): ${attachments.map((a) => a['name']).join(', ')}'
                : 'Tap to view memo details'));

    // Optimistic update in memory first so UI reflects immediately
    if (state is MemoLoaded) {
      final updatedList = (state as MemoLoaded).memos.map((m) {
        if (m.id != id) return m;
        return m.copyWith(
          title: title.trim(),
          content: content,
          preview: previewText,
          meta: 'Saved just now',
          tag: tag ?? m.tag,
          dueDate: dueDate ?? m.dueDate,
          checklistTitle: checklistTitle ?? m.checklistTitle,
          status: status ?? m.status,
          assignee: assignee ?? m.assignee,
          assigneeTone: assigneeTone ?? m.assigneeTone,
          assignees: assignees ?? m.assignees,
          attachments: attachments ?? m.attachments,
          checklist: checklist ?? m.checklist,
          progress: progress ?? m.progress,
          updatedAt: DateTime.now(),
        );
      }).toList();
      emit(MemoLoaded(updatedList));
    }

    try {
      if (FirebaseAuth.instance.currentUser != null &&
          workspaceId.isNotEmpty &&
          !id.startsWith('memo-')) {
        final updateData = <String, dynamic>{
          'title': title.trim(),
          'content': content,
          'preview': previewText,
          'meta': 'Saved just now',
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (tag != null) updateData['tag'] = tag;
        if (dueDate != null) updateData['dueDate'] = dueDate;
        if (checklistTitle != null) {
          updateData['checklistTitle'] = checklistTitle;
        }
        if (status != null) updateData['status'] = status;
        if (assignee != null) updateData['assignee'] = assignee;
        if (assigneeTone != null) updateData['assigneeTone'] = assigneeTone;
        if (assignees != null) updateData['assignees'] = assignees;
        if (attachments != null) updateData['attachments'] = attachments;
        if (checklist != null) {
          updateData['checklist'] = checklist;
          updateData['progress'] = progress;
        }

        await _firestore
            .collection('workspaces')
            .doc(workspaceId)
            .collection('memos')
            .doc(id)
            .update(updateData);
        try {
          await _writeActivity(
            workspaceId: workspaceId,
            memoId: id,
            type: 'memo_edited',
            targetTitle: title.trim(),
          );
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Update status kolom Kanban ('todo', 'doing', 'done') secara langsung saat drag & drop
  Future<void> updateMemoStatus(
    String workspaceId,
    String memoId,
    String newStatus,
  ) async {
    // Optimistic update agar perpindahan kartu di Kanban instan tanpa jeda
    if (state is MemoLoaded) {
      final updatedList = (state as MemoLoaded).memos.map((m) {
        if (m.id != memoId) return m;
        return m.copyWith(
          status: newStatus,
          meta: 'Moved just now',
          updatedAt: DateTime.now(),
        );
      }).toList();
      emit(MemoLoaded(updatedList));
    }

    final localIdx = _localMemos.indexWhere((m) => m.id == memoId);
    if (localIdx != -1) {
      _localMemos[localIdx] = _localMemos[localIdx].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    }

    try {
      if (FirebaseAuth.instance.currentUser != null &&
          workspaceId.isNotEmpty &&
          !memoId.startsWith('memo-')) {
        await _firestore
            .collection('workspaces')
            .doc(workspaceId)
            .collection('memos')
            .doc(memoId)
            .update({
          'status': newStatus,
          'meta': 'Moved just now',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
  }

  Future<void> delete(String workspaceId, String memoId) async {
    _localMemos.removeWhere((m) => m.id == memoId);
    if (state is MemoLoaded) {
      final remaining =
          (state as MemoLoaded).memos.where((m) => m.id != memoId).toList();
      emit(MemoLoaded(remaining));
    }

    try {
      if (FirebaseAuth.instance.currentUser != null &&
          workspaceId.isNotEmpty &&
          !memoId.startsWith('memo-')) {
        await _firestore
            .collection('workspaces')
            .doc(workspaceId)
            .collection('memos')
            .doc(memoId)
            .delete();
        try {
          await _firestore.collection('workspaces').doc(workspaceId).update({
            'memoCount': FieldValue.increment(-1),
          });
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> deleteMemo(String workspaceId, String memoId) =>
      delete(workspaceId, memoId);

  Future<void> updateMemoPosition(
    String workspaceId,
    String memoId,
    double x,
    double y,
  ) async {
    if (state is MemoLoaded) {
      final updatedList = (state as MemoLoaded).memos.map((m) {
        if (m.id != memoId) return m;
        return m.copyWith(boardX: x, boardY: y);
      }).toList();
      emit(MemoLoaded(updatedList));
    }

    try {
      if (FirebaseAuth.instance.currentUser != null &&
          workspaceId.isNotEmpty &&
          !memoId.startsWith('memo-')) {
        await _firestore
            .collection('workspaces')
            .doc(workspaceId)
            .collection('memos')
            .doc(memoId)
            .update({'boardX': x, 'boardY': y});
      }
    } catch (_) {}
  }

  Future<void> _writeActivity({
    required String workspaceId,
    String memoId = '',
    required String type,
    required String targetTitle,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('activities')
        .add({
      'type': type,
      'targetTitle': targetTitle,
      'workspaceId': workspaceId,
      'memoId': memoId,
      'actorId': user.uid,
      'actorName': user.displayName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> close() {
    _memosSubscription?.cancel();
    return super.close();
  }
}
