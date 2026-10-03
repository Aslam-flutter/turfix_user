class AuthModel {
  String uid;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String? photoUrl;
  final String role;
  final List? favoriteTurfs;

  AuthModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.photoUrl,
    this.favoriteTurfs,
    required this.role,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
      photoUrl: json['photoUrl'],
      favoriteTurfs: json['favorites'] ?? [],
      role: 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
      'favoriteTurfs': favoriteTurfs,
    };
  }
}
