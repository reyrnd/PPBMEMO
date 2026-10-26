enum MemberRole { owner, member }

class WorkspaceMember {
  final String userId;
  final String name;
  final String initials;
  final MemberRole role;

  const WorkspaceMember({
    required this.userId,
    required this.name,
    required this.initials,
    required this.role,
  });

  WorkspaceMember copyWith({
    String? userId,
    String? name,
    String? initials,
    MemberRole? role,
  }) {
    return WorkspaceMember(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      role: role ?? this.role,
    );
  }
}
