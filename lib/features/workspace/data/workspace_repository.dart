import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memospace/features/workspace/models/workspace.dart';
import 'package:rxdart/rxdart.dart';

class WorkspaceRepository {
  final _db = FirebaseFirestore.instance;
  User get _user => FirebaseAuth.instance.currentUser!;

  String _initials(String? name) {
    final p =
        (name ?? '?').trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    return (p.first[0] + (p.length > 1 ? p.last[0] : '')).toUpperCase();
  }

  Stream<List<Workspace>> watchWorkspaces() =>
      FirebaseAuth.instance.authStateChanges().switchMap((user) {
        if (user == null) return Stream.value(<Workspace>[]);
        return _db
            .collection('workspaces')
            .where('memberIds', arrayContains: user.uid)
            .snapshots()
            .map((s) =>
                s.docs.map((d) => Workspace.fromDoc(d, user.uid)).toList()
                  ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
      });

  Future<void> create({
    required String title,
    required String description,
    required String category,
    bool pin = false,
  }) async {
    final u = _user;
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final code =
        List.generate(6, (_) => chars[Random().nextInt(chars.length)]).join();
    final ref = _db.collection('workspaces').doc();
    final batch = _db.batch();
    batch.set(ref, {
      'title': title,
      'description': description,
      'category': category,
      'ownerId': u.uid,
      'memberIds': [u.uid],
      'members': {
        u.uid: {'name': u.displayName ?? '', 'role': 'owner'}
      },
      'memberInitials': [_initials(u.displayName)],
      'pinnedBy': pin ? [u.uid] : [],
      'inviteCode': code,
      'memoCount': 0,
      'fileCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection('invites').doc(code), {'workspaceId': ref.id});
    await batch.commit();
  }

  Future<void> joinByCode(String code) async {
    final u = _user;
    final invite =
        await _db.collection('invites').doc(code.trim().toUpperCase()).get();
    if (!invite.exists) throw Exception('Kode undangan tidak ditemukan.');
    await _db.collection('workspaces').doc(invite['workspaceId']).update({
      'memberIds': FieldValue.arrayUnion([u.uid]),
      'members.${u.uid}': {'name': u.displayName ?? '', 'role': 'member'},
      'memberInitials': FieldValue.arrayUnion([_initials(u.displayName)]),
    });
  }

  Future<void> inviteByEmail(String workspaceId, String email) async {
    final users = await _db
        .collection('users')
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();
    if (users.docs.isEmpty) {
      throw Exception('Akun dengan email tersebut tidak ditemukan.');
    }

    final invitedUser = users.docs.first;
    final userData = invitedUser.data();
    final name = userData['name'] as String? ?? '';
    final workspaceRef = _db.collection('workspaces').doc(workspaceId);

    await _db.runTransaction((transaction) async {
      final workspace = await transaction.get(workspaceRef);
      if (!workspace.exists) {
        throw Exception('Workspace tidak ditemukan.');
      }

      final memberIds =
          List<String>.from(workspace.data()?['memberIds'] ?? const []);
      if (memberIds.contains(invitedUser.id)) {
        throw Exception('Akun tersebut sudah menjadi anggota workspace.');
      }
      if (memberIds.length >= 10) {
        throw Exception('Workspace sudah mencapai batas 10 anggota.');
      }

      transaction.update(workspaceRef, {
        'memberIds': FieldValue.arrayUnion([invitedUser.id]),
        'members.${invitedUser.id}': {'name': name, 'role': 'member'},
        'memberInitials': FieldValue.arrayUnion([_initials(name)]),
      });
    });
  }

  Future<void> togglePin(String id, bool pin) =>
      _db.collection('workspaces').doc(id).update({
        'pinnedBy': pin
            ? FieldValue.arrayUnion([_user.uid])
            : FieldValue.arrayRemove([_user.uid]),
      });

  Future<void> rename(String id, String title) =>
      _db.collection('workspaces').doc(id).update({'title': title});

  Future<void> leave(String id) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('workspaces').doc(id).update({
      'memberIds': FieldValue.arrayRemove([uid]),
      'members.$uid': FieldValue.delete(),
    });
  }
}
