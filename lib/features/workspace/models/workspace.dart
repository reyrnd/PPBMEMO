import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memospace/features/workspace/models/workspace_member.dart';

class Workspace {
  final String id;
  final String category;
  final String title;
  final String description;
  final int memoCount;
  final int fileCount;
  final bool hasPin;
  final DateTime updatedAt;
  final List<String> memberInitials;
  final String inviteCode;
  final List<WorkspaceMember> members;
  final String ownerId;

  const Workspace({
    required this.id,
    required this.category,
    required this.title,
    this.description = '',
    required this.memoCount,
    required this.fileCount,
    this.hasPin = false,
    required this.updatedAt,
    this.memberInitials = const [],
    this.inviteCode = '',
    this.members = const [],
    this.ownerId = '',
  });

  String get name => title;
  int get memos => memoCount;

  /// Mengecek apakah user dengan [uid] adalah pemilik (owner) dari workspace ini.
  bool isOwnedBy(String? uid) {
    if (uid == null || uid.isEmpty) {
      return ownerId.isEmpty || ownerId == 'demo-naya';
    }
    if (ownerId == uid || ownerId == 'demo-naya') return true;
    final hasOwnerRole = members.any(
      (m) => m.userId == uid && m.role == MemberRole.owner,
    );
    if (hasOwnerRole) return true;
    if (ownerId.isEmpty && (members.isEmpty || members.first.userId == uid)) {
      return true;
    }
    return false;
  }

  Workspace copyWith({
    String? id,
    String? category,
    String? title,
    String? description,
    int? memoCount,
    int? fileCount,
    bool? hasPin,
    DateTime? updatedAt,
    List<String>? memberInitials,
    String? inviteCode,
    List<WorkspaceMember>? members,
    String? ownerId,
  }) {
    return Workspace(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      memoCount: memoCount ?? this.memoCount,
      fileCount: fileCount ?? this.fileCount,
      hasPin: hasPin ?? this.hasPin,
      updatedAt: updatedAt ?? this.updatedAt,
      memberInitials: memberInitials ?? this.memberInitials,
      inviteCode: inviteCode ?? this.inviteCode,
      members: members ?? this.members,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  factory Workspace.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc, String uid) {
    final d = doc.data();
    // data() bisa null jika dokumen belum dikonfirmasi server (pending write)
    if (d == null) {
      return Workspace(
        id: doc.id,
        category: '',
        title: '',
        memoCount: 0,
        fileCount: 0,
        updatedAt: DateTime.now(),
      );
    }
    final rawMembersMap = d['members'] as Map<String, dynamic>? ?? {};
    String resolvedOwnerId = (d['ownerId'] as String? ?? '').trim();
    if (resolvedOwnerId.isEmpty) {
      for (final entry in rawMembersMap.entries) {
        final mData = entry.value is Map
            ? Map<String, dynamic>.from(entry.value as Map)
            : const <String, dynamic>{};
        if (mData['role'] == 'owner') {
          resolvedOwnerId = entry.key;
          break;
        }
      }
    }

    return Workspace(
      id: doc.id,
      category: d['category'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      memoCount: d['memoCount'] ?? 0,
      fileCount: d['fileCount'] ?? 0,
      hasPin: (d['pinnedBy'] as List? ?? []).contains(uid),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memberInitials: List<String>.from(d['memberInitials'] ?? const []),
      inviteCode: d['inviteCode'] ?? '',
      ownerId: resolvedOwnerId,
      members: rawMembersMap.entries.map((e) {
        final memberData = Map<String, dynamic>.from(e.value as Map);
        final name = memberData['name'] as String? ?? '';
        final parts = name
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList();
        final initials = parts.isEmpty
            ? ''
            : (parts.first[0] + (parts.length > 1 ? parts.last[0] : ''))
                .toUpperCase();

        return WorkspaceMember(
          userId: e.key,
          name: name,
          initials: memberData['initials'] as String? ?? initials,
          role: memberData['role'] == 'owner'
              ? MemberRole.owner
              : MemberRole.member,
        );
      }).toList(),
    );
  }
}
