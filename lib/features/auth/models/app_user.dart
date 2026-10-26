class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1 && parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
    };
  }
}
