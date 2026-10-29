import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memospace/features/memo/models/memo.dart';
import 'package:rxdart/rxdart.dart';

class MemoRepository {
  final _db = FirebaseFirestore.instance;
  User get _user => FirebaseAuth.instance.currentUser!;

  CollectionReference<Map<String, dynamic>> _memos(String wsId) =>
      _db.collection('workspaces').doc(wsId).collection('memos');

  // Semua memo dari semua workspace milikku (Home dan Library), realtime
  Stream<List<Memo>> watchAllMyMemos() =>
      FirebaseAuth.instance.authStateChanges().switchMap((user) {
        if (user == null) return Stream.value(<Memo>[]);
        return _db
            .collection('workspaces')
            .where('memberIds', arrayContains: user.uid)
            .snapshots()
            .switchMap((snap) {
          if (snap.docs.isEmpty) return Stream.value(<Memo>[]);
          return Rx.combineLatestList(snap.docs.map((w) => w.reference
                  .collection('memos')
                  .snapshots()
                  .map((s) => s.docs.map(Memo.fromDoc).toList())))
              .map((lists) => lists.expand((l) => l).toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
        });
      });

  Stream<List<Memo>> watchWorkspaceMemos(String wsId) =>
      _memos(wsId).snapshots().map((s) => s.docs.map(Memo.fromDoc).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));

  Future<void> save(Memo m, {required bool isNew}) async {
    final u = _user;
    final wsRef = _db.collection('workspaces').doc(m.workspaceId);
    final memoRef = _memos(m.workspaceId).doc(m.id.isEmpty ? null : m.id);
    final batch = _db.batch();
    batch.set(
      memoRef,
      {
        ...m.toMap(),
        'authorId': u.uid,
        'authorName': u.displayName ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        if (isNew) 'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.update(wsRef, {
      if (isNew) 'memoCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(wsRef.collection('activities').doc(), {
      'actorId': u.uid,
      'actorName': u.displayName ?? '',
      'type': isNew ? 'memo_created' : 'memo_edited',
      'targetTitle': m.title,
      'memoId': memoRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> delete(String wsId, String memoId) async {
    final wsRef = _db.collection('workspaces').doc(wsId);
    final batch = _db.batch();
    batch.delete(_memos(wsId).doc(memoId));
    batch.update(wsRef, {'memoCount': FieldValue.increment(-1)});
    await batch.commit();
  }

  Future<void> toggleBookmark(String wsId, String memoId, bool on) =>
      _memos(wsId).doc(memoId).update({
        'bookmarkedBy': on
            ? FieldValue.arrayUnion([_user.uid])
            : FieldValue.arrayRemove([_user.uid]),
      });

  Future<void> setArchived(String wsId, String memoId, bool v) =>
      _memos(wsId).doc(memoId).update({'archived': v});
}
