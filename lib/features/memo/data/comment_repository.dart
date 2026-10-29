import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memospace/features/memo/models/comment.dart';

class CommentRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String wsId, String memoId) =>
      _db
          .collection('workspaces')
          .doc(wsId)
          .collection('memos')
          .doc(memoId)
          .collection('comments');

  Stream<List<Comment>> watch(String wsId, String memoId) =>
      _col(wsId, memoId).snapshots().map((snapshot) {
        final comments = snapshot.docs
            .map((doc) => Comment.fromDoc(doc, memoId))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return comments;
      });

  Stream<int> watchCount(String wsId, String memoId) =>
      _col(wsId, memoId).snapshots().map((snapshot) => snapshot.size);

  Future<void> add(String wsId, String memoId, String memoTitle, String text,
      {String? parentId}) async {
    final u = FirebaseAuth.instance.currentUser!;
    final batch = _db.batch();
    batch.set(_col(wsId, memoId).doc(), {
      'authorId': u.uid,
      'authorName': u.displayName ?? '',
      'text': text,
      'parentId': parentId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
        _db.collection('workspaces').doc(wsId).collection('activities').doc(), {
      'actorId': u.uid,
      'actorName': u.displayName ?? '',
      'type': 'comment_added',
      'targetTitle': memoTitle,
      'memoId': memoId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
