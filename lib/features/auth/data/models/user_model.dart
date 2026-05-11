class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool isActive;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:        json['id'] ?? 0,
      name:      json['name'] ?? '',
      email:     json['email'] ?? '',
      role:      json['role'] ?? '',
      phone:     json['phone'],
      isActive:  json['is_active'] ?? true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':         id,
      'name':       name,
      'email':      email,
      'role':       role,
      'phone':      phone,
      'is_active':  isActive,
      'created_at': createdAt,
    };
  }

  // Helper role
  bool get isOwner => role == 'owner';
  bool get isHead  => role == 'head';
  bool get isAdmin => role == 'admin';

  String get roleLabel {
    switch (role) {
      case 'owner': return 'Owner';
      case 'head':  return 'Kepala Toko';
      case 'admin': return 'Admin Toko';
      default:      return role;
    }
  }
}