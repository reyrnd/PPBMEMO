import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memospace/features/auth/models/app_user.dart';
import 'package:rxdart/rxdart.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  Stream<AppUser?> watchMe() =>
      FirebaseAuth.instance.authStateChanges().switchMap((u) => u == null
          ? Stream.value(null)
          : _db
              .collection('users')
              .doc(u.uid)
              .snapshots()
              .map((d) => d.exists ? AppUser.fromDoc(d) : null));

  Future<void> updateProfile({required String name, String? bio}) async {
    final u = FirebaseAuth.instance.currentUser!;
    await u.updateDisplayName(name);
    await _db
        .collection('users')
        .doc(u.uid)
        .set({'name': name, 'bio': bio ?? ''}, SetOptions(merge: true));
  }
}
