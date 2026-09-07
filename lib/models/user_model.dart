class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'salesman' or 'manager'
  final String? photoUrl;
  final List<String> linkedManagers;
  final List<String> linkedSalesmen;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.linkedManagers = const [],
    this.linkedSalesmen = const [],
    required this.createdAt,
  });

  // Convert UserModel to a Map so Firebase can store it
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'linkedManagers': linkedManagers,
      'linkedSalesmen': linkedSalesmen,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert Firebase data back into a UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'salesman',
      photoUrl: map['photoUrl'],
      linkedManagers: List<String>.from(map['linkedManagers'] ?? []),
      linkedSalesmen: List<String>.from(map['linkedSalesmen'] ?? []),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
