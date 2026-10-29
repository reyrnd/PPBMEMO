import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memospace/features/activity/models/activity.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/transformers.dart';

class ActivityRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<Activity>> watchWorkspaceActivities({
    required String workspaceId,
    required String workspaceName,
  }) =>
      _db
          .collection('workspaces')
          .doc(workspaceId)
          .collection('activities')
          .orderBy('createdAt', descending: true)
          .limit(30)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Activity.fromDoc(doc, workspaceName))
              .toList());

  Stream<List<Activity>> watchAllMyActivities() =>
      FirebaseAuth.instance.authStateChanges().switchMap((user) {
        if (user == null) return Stream.value(<Activity>[]);
        return _db
            .collection('workspaces')
            .where('memberIds', arrayContains: user.uid)
            .snapshots()
            .switchMap((snap) {
          if (snap.docs.isEmpty) return Stream.value(<Activity>[]);
          return Rx.combineLatestList(snap.docs.map((w) => w.reference
              .collection('activities')
              .orderBy('createdAt', descending: true)
              .limit(30)
              .snapshots()
              .map((s) => s.docs
                  .map((d) => Activity.fromDoc(d, w.data()['title'] ?? ''))
                  .toList()))).map((lists) => lists.expand((l) => l).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
        });
      });
}
